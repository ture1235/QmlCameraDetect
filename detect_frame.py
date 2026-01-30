import queue
import sys
import os
import time
import cv2
import numpy as np
from pathlib import Path

from PySide6.QtCore import QObject, Slot, QMetaObject, Q_ARG, QSize
from PySide6.QtMultimedia import QVideoFrame, QVideoSink, QVideoFrame, QVideoFrameFormat


from convert import mjpeg_qvideo_frame_to_cv, nv12_qvideo_frame_to_cv
from load_model import YoloModelWorker, DETECT_QUEUE





class FrameHandler(QObject):
    """视频帧处理类,通过 QVideoSink 接收视频帧"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.frame_count = 0
        # 创建 VideoSink 用于接收帧
        self.video_sink = QVideoSink(self)
        # 保存 detectionOverlay 的引用
        self.detection_overlay = None
        # 保存 videoSink 的引用
        self._video_sink_source = None
        # 连接状态
        self._is_connected = False
        print("[FrameHandler] Initialized with QVideoSink")
        print(f"[FrameHandler] VideoSink object: {self.video_sink}")
        self.model_path = ''  # 模型路径
        self.model_detection_frequency = 0.5  # 模型检测频率
        self.model_device = 'cpu'  # 模型设备 以上三个参数与qml界面设置绑定
        self.model_worker = YoloModelWorker()
        self.model_worker.prediction_finished.connect(self.set_detections)
        self.last_detection_time = 0  # 上次推入帧的时间
    
    def connect_to_source(self, video_sink):
        """连接到视频源的 VideoSink"""
        if self._is_connected:
            print("[FrameHandler] Already connected, disconnecting first...")
            self.disconnect_from_source()
        
        self._video_sink_source = video_sink
        if video_sink:
            video_sink.videoFrameChanged.connect(self.on_frame_changed)
            self._is_connected = True
            print("[FrameHandler] ✅ Connected to VideoSink - Frame processing ENABLED")
            self.model_worker.model_loader.model_path = r"D:\python_projects\YoloTest\best.pt"
            # time.sleep(1)
            self.model_worker.start()
        else:
            print("[FrameHandler] ❌ ERROR: video_sink is None")
    
    def disconnect_from_source(self):
        """断开与视频源的连接"""
        if self._is_connected and self._video_sink_source:
            try:
                self._video_sink_source.videoFrameChanged.disconnect(self.on_frame_changed)
                self._is_connected = False
                # self.model_worker.stop()
                # self.model_worker.unload_model()
                print("[FrameHandler] ⏸️  Disconnected from VideoSink - Frame processing DISABLED")
            except Exception as e:
                print(f"[FrameHandler] Warning: Failed to disconnect: {e}")
        else:
            print("[FrameHandler] Already disconnected")
        self.model_worker.stop()
        self.model_worker.unload_model()
        self.clear_detections()

    @property
    def is_connected(self):
        """返回当前连接状态"""
        return self._is_connected
    
    @Slot(result=bool)
    def get_connection_status(self):
        """获取当前连接状态 (供 QML 调用)"""
        return self._is_connected
    
    @Slot()
    def toggle_connection(self):
        """切换连接状态 (可从 QML 调用)"""
        if self._is_connected:
            self.disconnect_from_source()
        else:
            if self._video_sink_source:
                self.connect_to_source(self._video_sink_source)
            else:
                print("[FrameHandler] ERROR: No video sink source available")
    
    @Slot(QVideoFrame)
    def on_frame_changed(self, frame):
        """当新帧到达时调用"""
        if frame is None or not frame.isValid():
            return
        
        self.frame_count += 1
        current_time = time.time()
        if current_time - self.last_detection_time >= self.model_detection_frequency:
            a = time.time()
            if frame.surfaceFormat().pixelFormat() == QVideoFrameFormat.PixelFormat.Format_NV12:
                frame = nv12_qvideo_frame_to_cv(frame)
            elif frame.surfaceFormat().pixelFormat() == QVideoFrameFormat.PixelFormat.Format_Jpeg:
                frame = mjpeg_qvideo_frame_to_cv(frame)
            b = time.time()
            print(f"[格式转换] 耗时: {b-a}")
            # 这里处理一下推理来不及，丢弃当前帧
            try:
                DETECT_QUEUE.put_nowait(frame)
            except queue.Full:
                print("[Python] 队列已满，丢弃当前帧")
            self.last_detection_time = current_time
    
    @Slot(QVideoFrame)
    def receiveFrame(self, frame):
        """从QML接收视频帧（由QML直接调用）"""
        print(f"[Python] receiveFrame called, frame={frame}")
        
        if frame is None or not frame.isValid():
            print("[Python] Frame is None or invalid")
            return
        
        self.frame_count += 1
        print(f"[Python] Valid frame received! count={self.frame_count}")
        
        # 每30帧打印一次详细信息
        if self.frame_count % 30 == 0:
            print(f"\n[Python] ===== Frame #{self.frame_count} =====")
            print(f"  Size: {frame.width()}x{frame.height()}")
            print(f"  PixelFormat: {frame.pixelFormat()}")
            print("=" * 50)
    
    def add_detection(self, x1, y1, x2, y2, label="检测目标", confidence=0.9, color="red"):
        """添加一个检测框"""
        if not self.detection_overlay:
            print("[Python] ERROR: detection_overlay not set")
            return
        
        detection = {
            "x1": x1,
            "y1": y1,
            "x2": x2,
            "y2": y2,
            "label": label,
            "confidence": confidence,
            "color": color
        }
        
        # 调用 QML 的 addDetection 方法
        QMetaObject.invokeMethod(self.detection_overlay, "addDetection",
                                 Q_ARG("QVariant", detection))
    
    def set_detections(self, detections):
        """批量设置检测框
        
        Args:
            detections: list of dict, 每个dict包含: x, y, width, height, label, confidence, color
        """
        if not self.detection_overlay:
            print("[Python] ERROR: detection_overlay not set")
            return
        
        # 调用 QML 的 setDetections 方法
        QMetaObject.invokeMethod(self.detection_overlay, "setDetections",
                                 Q_ARG("QVariant", detections))
    
    def clear_detections(self):
        """清除所有检测框"""
        if not self.detection_overlay:
            print("[Python] ERROR: detection_overlay not set")
            return
        
        # 调用 QML 的 clearDetections 方法
        QMetaObject.invokeMethod(self.detection_overlay, "clearDetections")
    
    def setVideoDefaultFormat(self, format):
        if not self.detection_overlay:
            print("[Python] ERROR: detection_overlay not set")
            return
        QMetaObject.invokeMethod(self.detection_overlay, "setVideoDefaultFormat",
                                  Q_ARG("QVariant", format))

    def get_current_frame(self):
        """获取当前帧"""
        # 这里传格式过去qml好像不好处理，传个大小过去算了，默认只让使用mjpeg格式,如果进来是其他格式，默认格式给它上设置同等大小的mjpeg格式，第二次点击生效
        if self._video_sink_source:
            frame = self._video_sink_source.videoFrame()
            format = frame.surfaceFormat()
            resolution = QSize(format.frameWidth(), format.frameHeight())
            self.setVideoDefaultFormat(resolution)
        else:
            print("[Python] ERROR: No video sink source available")
