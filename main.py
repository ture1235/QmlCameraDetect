#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
QML Camera Application
使用 PySide6 启动的相机应用程序
"""

import sys
import os


from pathlib import Path
from PySide6.QtCore import QUrl, QCoreApplication, QObject, QTimer
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


from detect_frame import FrameHandler



def main():
    """主函数"""
    # GT 1030 不支持 NVENC 硬件编码,强制使用 CPU 软件编码器
    os.environ["CUDA_VISIBLE_DEVICES"] = ""
    
    # 创建应用程序实例
    app = QApplication(sys.argv)
    app.setOrganizationName("MyCompany")
    app.setApplicationName("QML Camera")
    
    # 创建帧处理器实例
    frame_handler = FrameHandler()
    
    # 创建 QML 引擎
    engine = QQmlApplicationEngine()
    
    # 将帧处理器暴露给 QML (如果需要在QML中直接访问)
    engine.rootContext().setContextProperty("frameHandler", frame_handler)
    
    # 获取当前脚本所在目录
    current_dir = Path(__file__).parent.resolve()
    
    # 连接对象创建失败的信号
    def on_object_creation_failed():
        """QML 对象创建失败时的回调"""
        print("Error: Failed to create QML object")
        QCoreApplication.exit(-1)
    
    engine.objectCreationFailed.connect(on_object_creation_failed)
    
    # 加载 Main.qml 文件
    main_qml_path = current_dir / "Main.qml"
    
    if not main_qml_path.exists():
        print(f"Error: Main.qml not found at {main_qml_path}")
        return -1
    
    # 添加导入路径
    engine.addImportPath(str(current_dir))
    
    # 加载 QML 文件
    engine.load(QUrl.fromLocalFile(str(main_qml_path)))
    
    # 检查是否成功加载
    if not engine.rootObjects():
        print("Error: No root objects created")
        return -1
    
    # QML 加载完成后,准备 VideoSink 连接 (但不立即连接)
    root = engine.rootObjects()[0]
    if root:
        # 查找 cameraShow (DeclarativeCamera 实例)
        camera_show = root.findChild(QObject, "cameraShow")
        if camera_show:
            print("[Python] Found cameraShow")
            
            # 查找 detectionOverlay
            detection_overlay = camera_show.findChild(QObject, "detectionOverlay")
            if detection_overlay:
                print("[Python] Found detectionOverlay")
                
                # 获取 detectionOverlay 暴露的 videoSink 属性
                video_sink = detection_overlay.property("videoSink")
                if video_sink:
                    print(f"[Python] Got VideoSink: {video_sink},", type(video_sink))
                    
                    # 保存 detection_overlay 引用
                    frame_handler.detection_overlay = detection_overlay
                    
                    # ⚠️ 默认不连接,避免性能开销
                    # 需要处理帧时调用: frame_handler.connect_to_source(video_sink)
                    frame_handler._video_sink_source = video_sink
                    print("[Python] ⏸️  VideoSink ready but NOT connected (save performance)")
                    print("[Python] 💡 Call frame_handler.connect_to_source(video_sink) to enable frame processing")
                    # 启动一个延迟3s的定时器,延迟启动获取当前帧的格式
                    QTimer.singleShot(3000, lambda: frame_handler.get_current_frame())
                    # 如果需要立即启用,取消下面这行的注释:
                    # frame_handler.connect_to_source(video_sink)
                else:
                    print("[Python] ERROR: Could not get videoSink from detectionOverlay")
            else:
                print("[Python] ERROR: Could not find detectionOverlay")
        else:
            print("[Python] ERROR: Could not find cameraShow")
    else:
        print("[Python] ERROR: Could not get root object")
    
    # 运行应用程序事件循环
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
