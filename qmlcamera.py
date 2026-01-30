#!/usr/bin/env python3
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import sys
import os
from pathlib import Path

from PySide6.QtCore import QUrl, QObject, Slot, QMetaObject, Q_ARG
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlEngine, QQmlApplicationEngine
from PySide6.QtQuick import QQuickView
from PySide6.QtMultimedia import QVideoFrame, QVideoSink, QMediaCaptureSession

# 检查是否支持权限系统
try:
    from PySide6.QtCore import QCameraPermission, QPermission, Qt
    HAS_PERMISSIONS = True
except ImportError:
    HAS_PERMISSIONS = False


class FrameHandler(QObject):
    """视频帧处理类,通过 QVideoSink 接收视频帧"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.frame_count = 0
        # 创建 VideoSink 用于接收帧
        self.video_sink = QVideoSink(self)
        # 连接信号 - 这是接收帧的关键
        self.video_sink.videoFrameChanged.connect(self.on_frame_changed)
        # 保存 detectionOverlay 的引用
        self.detection_overlay = None
        print("[FrameHandler] Initialized with QVideoSink")
        print(f"[FrameHandler] VideoSink object: {self.video_sink}")
    
    @Slot(QVideoFrame)
    def on_frame_changed(self, frame):
        """当新帧到达时调用"""
        if frame is None or not frame.isValid():
            return
        
        self.frame_count += 1
        
        # 每60帧打印一次信息
        # if self.frame_count % 60 == 0:
        print(f"\n[Python] Received Frame #{self.frame_count}")
        print(f"  Size: {frame.width()}x{frame.height()}")
        print(f"  PixelFormat: {frame.pixelFormat()}")
        print("-" * 40)
        
        # 示例: 每100帧添加一个测试检测框
        if self.frame_count % 100 == 0 and self.detection_overlay:
            import random
            # 清除旧的检测框
            self.clear_detections()
            
            # 添加一些随机检测框作为演示
            detections = [
                {
                    "x": random.randint(100, 800),
                    "y": random.randint(100, 500),
                    "width": 150,
                    "height": 150,
                    "label": "目标A",
                    "confidence": 0.95,
                    "color": "green"
                },
                {
                    "x": random.randint(100, 800),
                    "y": random.randint(100, 500),
                    "width": 100,
                    "height": 100,
                    "label": "目标B",
                    "confidence": 0.87,
                    "color": "blue"
                }
            ]
            self.set_detections(detections)
            print(f"[Python] Added {len(detections)} detection boxes")
    
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
    
    def add_detection(self, x, y, width, height, label="检测目标", confidence=0.9, color="red"):
        """添加一个检测框"""
        if not self.detection_overlay:
            print("[Python] ERROR: detection_overlay not set")
            return
        
        detection = {
            "x": x,
            "y": y,
            "width": width,
            "height": height,
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


def main():
    # GT 1030 不支持 NVENC 硬件编码,强制使用 CPU 软件编码器
    # 通过环境变量禁用所有 NVIDIA 硬件编码器
    os.environ['CUDA_VISIBLE_DEVICES'] = ''  # 让 FFmpeg 看不到 CUDA 设备
    os.environ['FFMPEG_VIDEO_ENCODER'] = 'libx264'  # 指定使用 libx264 软件编码
    
    app = QGuiApplication(sys.argv)
    
    # 创建帧处理器实例
    frame_handler = FrameHandler()
    
    view = QQuickView()
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    
    # 将帧处理器暴露给 QML
    view.engine().rootContext().setContextProperty("frameHandler", frame_handler)
    
    def setup_view(view_source: QUrl):
        """设置视图并显示"""
        # 连接退出信号
        view.engine().quit.connect(app.quit)
        view.setSource(view_source)
        view.show()
        
        # 等待 QML 加载完成后,从 detectionOverlay 获取 videoSink
        root = view.rootObject()
        if root:
            # 查找 detectionOverlay
            detection_overlay = root.findChild(QObject, "detectionOverlay")
            if detection_overlay:
                print("[Python] Found detectionOverlay")
                
                # 直接获取 detectionOverlay 暴露的 videoSink 属性
                video_sink = detection_overlay.property("videoSink")
                if video_sink:
                    print(f"[Python] Got VideoSink: {video_sink}")
                    # 监听 VideoSink 的帧更新信号
                    video_sink.videoFrameChanged.connect(frame_handler.on_frame_changed)
                    print("[Python] Connected to VideoSink signal!")
                    
                    # 保存 detection_overlay 引用,供后续绘制检测框使用
                    frame_handler.detection_overlay = detection_overlay
                else:
                    print("[Python] ERROR: Could not get videoSink from detectionOverlay")
            else:
                print("[Python] ERROR: Could not find detectionOverlay")
        else:
            print("[Python] ERROR: Could not get root object")
    
    # 获取当前脚本所在目录
    current_dir = Path(__file__).parent
    
    # 处理权限请求
    if HAS_PERMISSIONS:
        camera_permission = QCameraPermission()
        
        def handle_permission(permission):
            if permission.status() == Qt.PermissionStatus.Denied:
                # 权限被拒绝，显示权限拒绝界面
                qml_file = current_dir / "permission-denied.qml"
                setup_view(QUrl.fromLocalFile(str(qml_file)))
            else:
                # 权限通过，显示相机界面
                qml_file = current_dir / "declarative-camera.qml"
                setup_view(QUrl.fromLocalFile(str(qml_file)))
        
        # 检查权限状态
        permission_status = app.checkPermission(camera_permission)
        if permission_status == Qt.PermissionStatus.Undetermined:
            # 权限未确定，请求权限
            app.requestPermission(camera_permission, handle_permission)
        elif permission_status == Qt.PermissionStatus.Denied:
            # 权限被拒绝，显示权限拒绝界面
            qml_file = current_dir / "permission-denied.qml"
            setup_view(QUrl.fromLocalFile(str(qml_file)))
        else:
            # 权限已授予，显示相机界面
            qml_file = current_dir / "declarative-camera.qml"
            setup_view(QUrl.fromLocalFile(str(qml_file)))
    else:
        # 不支持权限系统，直接显示相机界面
        qml_file = current_dir / "declarative-camera.qml"
        setup_view(QUrl.fromLocalFile(str(qml_file)))
    
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
