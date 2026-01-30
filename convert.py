import cv2
import numpy as np
from PySide6.QtMultimedia import QVideoFrame, QVideoFrameFormat

def nv12_qvideo_frame_to_cv(video_frame: QVideoFrame, target_format='BGR'):
    """
    将 NV12 格式的 QVideoFrame 转换为 OpenCV 图像
    
    Args:
        video_frame: NV12 格式的 QVideoFrame
        target_format: 目标格式 'BGR' 或 'RGB'
    
    Returns:
        numpy.ndarray 或 None
    """
    if not video_frame or not video_frame.isValid():
        print("无效的 QVideoFrame")
        return None
    
    # 检查是否为 NV12 格式
    frame_format = video_frame.surfaceFormat()
    
    # 映射帧以访问数据
    if not video_frame.map(QVideoFrame.ReadOnly):
        print("无法映射 QVideoFrame")
        return None
    
    try:
        # 获取帧尺寸
        width = frame_format.frameSize().width()
        height = frame_format.frameSize().height()
        
        # 获取步长（stride）
        y_stride = video_frame.bytesPerLine(0)  # Y平面步长
        uv_stride = video_frame.bytesPerLine(1) if video_frame.planeCount() > 1 else y_stride  # UV平面步长
        
        # 获取数据指针
        y_plane_ptr = video_frame.bits(0)
        uv_plane_ptr = video_frame.bits(1) if video_frame.planeCount() > 1 else y_plane_ptr + (y_stride * height)
        
        # 方法1：使用 OpenCV 的 cvtColorTwoPlane（最快）
        if y_stride == width and (uv_stride == width or uv_stride == width // 2 * 2):
            # 连续内存，可以直接处理
            y_plane = np.frombuffer(y_plane_ptr[:y_stride * height], dtype=np.uint8)
            uv_plane = np.frombuffer(uv_plane_ptr[:uv_stride * height // 2], dtype=np.uint8)
            
            # 重塑形状
            y_plane = y_plane.reshape((height, y_stride))
            uv_plane = uv_plane.reshape((height // 2, uv_stride // 2, 2))
            
            # 如果是连续的，可以直接使用
            if y_stride == width:
                y_plane = y_plane[:, :width]
            else:
                # 需要去除填充
                y_plane = y_plane[:, :width]
            
            # 转换 NV12 -> BGR
            if uv_stride == width:
                uv_plane = uv_plane[:, :width, :]
            elif uv_stride == width // 2 * 2:
                uv_plane = uv_plane[:, :width//2, :]
            
            # 使用 OpenCV 转换
            bgr = cv2.cvtColorTwoPlane(y_plane, uv_plane, cv2.COLOR_YUV2BGR_NV12)
            
        else:
            # 方法2：处理带步长的情况
            # 提取 Y 平面
            y_plane = np.zeros((height, width), dtype=np.uint8)
            for i in range(height):
                start = i * y_stride
                y_row = y_plane_ptr[start:start + width]
                y_plane[i] = np.frombuffer(y_row, dtype=np.uint8)
            
            # 提取 UV 平面
            uv_height = height // 2
            uv_width = width // 2
            uv_plane = np.zeros((uv_height, uv_width, 2), dtype=np.uint8)
            
            for i in range(uv_height):
                start = i * uv_stride
                uv_row = uv_plane_ptr[start:start + uv_width * 2]
                uv_data = np.frombuffer(uv_row, dtype=np.uint8)
                # 交错存储的 UV 数据：U0, V0, U1, V1, ...
                uv_plane[i, :, 0] = uv_data[0::2]  # U
                uv_plane[i, :, 1] = uv_data[1::2]  # V
            
            # 调整 UV 平面形状以匹配 OpenCV 期望的格式
            uv_plane = uv_plane.reshape((uv_height, uv_width * 2))
            
            # 转换 NV12 -> BGR
            bgr = cv2.cvtColorTwoPlane(y_plane, uv_plane, cv2.COLOR_YUV2BGR_NV12)
        
        # 转换为目标格式
        if target_format.upper() == 'RGB':
            return cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
        else:
            return bgr
            
    except Exception as e:
        print(f"NV12 转换失败: {e}")
        import traceback
        traceback.print_exc()
        return None
    finally:
        video_frame.unmap()


def mjpeg_qvideo_frame_to_cv(video_frame: QVideoFrame):
    """
    将 MJPEG 格式的 QVideoFrame 转换为 OpenCV 图像
    MJPEG 是 Motion JPEG，每个帧都是 JPEG 压缩数据
    
    Args:
        video_frame: MJPEG 格式的 QVideoFrame
    
    Returns:
        numpy.ndarray (BGR格式) 或 None
    """
    if not video_frame or not video_frame.isValid():
        print("无效的 QVideoFrame")
        return None
    
    # 映射帧以访问数据
    if not video_frame.map(QVideoFrame.ReadOnly):
        print("无法映射 QVideoFrame")
        return None
    
    try:
        # 获取 MJPEG 数据（JPEG 压缩数据）
        data_ptr = video_frame.bits(0)
        data_size = video_frame.mappedBytes(0)
        
        if data_size == 0:
            print("MJPEG 数据大小为 0")
            return None
        
        # 将数据转换为字节数组
        jpeg_data = bytes(data_ptr[:data_size])
        
        # 使用 OpenCV 解码 JPEG 数据
        # 方法1：使用 imdecode（推荐）
        nparr = np.frombuffer(jpeg_data, np.uint8)
        cv_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if cv_image is None:
            print("OpenCV 解码 JPEG 失败，尝试其他方法")
        
        return cv_image  # 已经是 BGR 格式
        
    except Exception as e:
        print(f"转换 MJPEG 失败: {e}")
        import traceback
        traceback.print_exc()
        return None
    finally:
        video_frame.unmap()

