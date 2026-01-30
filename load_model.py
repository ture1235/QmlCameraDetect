"""
YOLO模型加载类
用于加载和管理YOLO模型，提供模型预测功能
"""

from doctest import FAIL_FAST
import os
import sys
from pathlib import Path
from PySide6.QtCore import QThread, Signal, QObject
from ultralytics import YOLO
import torch
import queue
import time



DETECT_QUEUE = queue.Queue(maxsize=1)


class YoloModelLoader(QObject):
    """
    YOLO模型加载器类
    用于加载、管理和使用YOLO模型进行预测
    """
    
    # 定义信号
    model_loaded = Signal(bool)  # 模型加载完成信号，参数为是否成功
    prediction_started = Signal()  # 预测开始信号
    prediction_finished = Signal(object)  # 预测完成信号，参数为预测结果
    error_occurred = Signal(str)  # 错误信号，参数为错误信息
    
    def __init__(self, model_path=None, device='cpu'):
        """
        初始化模型加载器
        
        Args:
            model_path (str): 模型文件路径，默认为None
            device (str): 运行设备，'cpu' 或 'cuda'，默认为'cpu'
        """
        super().__init__()
        self.model_path = model_path
        self.device = device
        self.model = None
        self.is_model_loaded = False
        
        # 检查CUDA可用性
        if device == 'cuda' and not torch.cuda.is_available():
            print("CUDA不可用，切换到CPU")
            self.device = 'cpu'
    
    def load_model(self, model_path=None):
        """
        加载YOLO模型
        
        Args:
            model_path (str): 模型文件路径，如果为None则使用初始化时的路径
            
        Returns:
            bool: 加载是否成功
        """
        try:
            if model_path:
                self.model_path = model_path
            
            if not self.model_path:
                # 如果没有指定模型路径，尝试使用默认模型
                self.model_path = "yolo11n.pt"
                print(f"未指定模型路径，使用默认模型: {self.model_path}")
            
            print(f"正在加载模型: {self.model_path}")
            print(f"运行设备: {self.device}")
            
            # 加载模型
            self.model = YOLO(self.model_path)
            
            # 将模型移动到指定设备
            if self.device == 'cuda':
                self.model = self.model.to('cuda')
            else:
                self.model = self.model.to('cpu')
            
            self.is_model_loaded = True
            print(f"模型加载成功: {self.model_path}")
            
            # 发射模型加载完成信号
            self.model_loaded.emit(True)
            return True
            
        except Exception as e:
            error_msg = f"模型加载失败: {str(e)}"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            self.model_loaded.emit(False)
            return False
    
    def predict(self, source, **kwargs):
        """
        使用模型进行预测
        
        Args:
            source: 预测源（图像、视频、路径等）
            **kwargs: 其他预测参数（如conf, iou等）
            
        Returns:
            Results: 预测结果对象
        """
        if not self.is_model_loaded or self.model is None:
            error_msg = "模型未加载，请先加载模型"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return None
        
        try:
            # self.prediction_started.emit()
            
            # 默认参数
            default_params = {
                'conf': 0.25,  # 置信度阈值
                'iou': 0.45,   # NMS IoU阈值
                'imgsz': 640,  # 输入图像大小
                'half': False, # 是否使用半精度
                'device': self.device,  # 设备
                'verbose': False  # 是否显示详细信息
            }
            
            # 更新参数
            default_params.update(kwargs)
            
            # 执行预测
            res = self.model.predict(source, **default_params)[0]
            if len(res.boxes) > 0:
                boxes = res.boxes.xyxy.tolist()
                confidence = res.boxes.conf.tolist()
                cls_ids = res.boxes.cls.tolist()
                
                rect_list = []
                for i, box in enumerate(boxes):
                    rect_info = {
                        "x1": int(box[0]),
                        "y1": int(box[1]),
                        "x2": int(box[2]),
                        "y2": int(box[3]),
                        "label": res.names.get(int(cls_ids[i]), None),
                        "confidence": round(confidence[i], 2)
                    }
                    rect_list.append(rect_info)
                
                self.prediction_finished.emit(rect_list)
                return rect_list
            else:
                self.prediction_finished.emit([])
            
            # self.prediction_finished.emit(results)
            return []
            
        except Exception as e:
            error_msg = f"预测过程中发生错误: {str(e)}"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return []
    
    def segment(self, source, **kwargs):
        """
        使用模型进行分割预测
        
        Args:
            source: 预测源
            **kwargs: 其他预测参数
            
        Returns:
            Results: 分割预测结果对象
        """
        if not self.is_model_loaded or self.model is None:
            error_msg = "模型未加载，请先加载模型"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return None
        
        try:
            self.prediction_started.emit()
            
            # 默认参数
            default_params = {
                'conf': 0.25,
                'iou': 0.45,
                'imgsz': 640,
                'half': False,
                'device': self.device,
                'verbose': False
            }
            
            default_params.update(kwargs)
            
            # 执行分割预测
            results = self.model.segment(source, **default_params)
            
            self.prediction_finished.emit(results)
            return results
            
        except Exception as e:
            error_msg = f"分割预测过程中发生错误: {str(e)}"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return None
    
    def classify(self, source, **kwargs):
        """
        使用模型进行分类预测
        
        Args:
            source: 预测源
            **kwargs: 其他预测参数
            
        Returns:
            Results: 分类预测结果对象
        """
        if not self.is_model_loaded or self.model is None:
            error_msg = "模型未加载，请先加载模型"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return None
        
        try:
            self.prediction_started.emit()
            
            # 默认参数
            default_params = {
                'conf': 0.25,
                'imgsz': 640,
                'half': False,
                'device': self.device,
                'verbose': False
            }
            
            default_params.update(kwargs)
            
            # 执行分类预测
            results = self.model.classify(source, **default_params)
            
            self.prediction_finished.emit(results)
            return results
            
        except Exception as e:
            error_msg = f"分类预测过程中发生错误: {str(e)}"
            print(error_msg)
            self.error_occurred.emit(error_msg)
            return None
    
    def get_model_info(self):
        """
        获取模型信息
        
        Returns:
            dict: 包含模型信息的字典
        """
        if not self.is_model_loaded or self.model is None:
            return {"error": "模型未加载"}
        
        try:
            # 获取模型名称
            model_name = getattr(self.model, 'name', 'Unknown')
            
            # 获取类别数量
            nc = getattr(self.model.model, 'nc', 0) if hasattr(self.model, 'model') else 0
            
            # 获取类别名称
            names = getattr(self.model.model, 'names', {}) if hasattr(self.model, 'model') else {}
            
            return {
                "model_name": model_name,
                "num_classes": nc,
                "class_names": names,
                "device": self.device,
                "is_loaded": self.is_model_loaded
            }
        except Exception as e:
            return {"error": f"获取模型信息时发生错误: {str(e)}"}
    
    def unload_model(self):
        """
        卸载模型，释放内存
        """
        if self.model:
            del self.model
            self.model = None
            self.is_model_loaded = False
            print("模型已卸载")
        else:
            print("没有加载的模型需要卸载")


class YoloModelWorker(QThread):
    """
    YOLO模型工作线程
    用于在后台加载模型和执行预测，避免阻塞主线程
    """
    
    # 定义信号
    model_loaded = Signal(bool)
    prediction_finished = Signal(object)
    error_occurred = Signal(str)
    
    def __init__(self, model_path=None, device='cpu', detection_frequency=0.5):
        """
        初始化模型工作线程
        
        Args:
            model_path (str): 模型文件路径
            device (str): 运行设备
            detection_frequency (float): 检测频率（秒）
        """
        super().__init__()
        self.model_loader = YoloModelLoader(model_path, device)
        
        # 连接信号
        self.model_loader.model_loaded.connect(self.model_loaded)
        self.model_loader.prediction_finished.connect(self.prediction_finished)
        self.model_loader.error_occurred.connect(self.error_occurred)
        self.active = False
        self.detection_frequency = detection_frequency  # 检测频率（秒）
        self.last_detection_time = 0  # 上次检测时间
    
    def run(self):
        """
        线程主函数
        """
        # 启动时自动加载模型
        if not self.model_loader.is_model_loaded:
            print("模型未加载，先加载模型")

            self.model_loader.load_model()
            # return
        self.active = True
        while self.active:
            current_time = time.time()
            if current_time - self.last_detection_time < self.detection_frequency:
                QThread.msleep(10)  # 减少CPU使用
                continue
            
            try:
                frame = DETECT_QUEUE.get_nowait()
            except Exception as e:
                QThread.msleep(10)  # 减少CPU使用
                continue
            else:
                # 更新上次检测时间
                self.last_detection_time = current_time
                self.model_loader.predict(frame)

        # 清除检测历史
        self.prediction_finished.emit([])
    

    def stop(self):
        """
        停止线程
        """
        self.active = False
    
    def load_model(self, model_path):
        """
        在工作线程中加载模型
        
        Args:
            model_path (str): 模型文件路径
        """
        return self.model_loader.load_model(model_path)
    
    def unload_model(self):
        """
        卸载模型
        """
        return self.model_loader.unload_model()
    
    def predict(self, source, **kwargs):
        """
        在工作线程中执行预测
        
        Args:
            source: 预测源
            **kwargs: 预测参数
        """
        return self.model_loader.predict(source, **kwargs)


if __name__ == "__main__":
    # 测试代码
    import sys
    from PySide6.QtWidgets import QApplication
    
    app = QApplication(sys.argv)
    
    # 创建模型加载器
    model_loader = YoloModelLoader("yolo11n.pt", device='cpu')
    
    # 连接信号
    def on_model_loaded(success):
        print(f"模型加载{'成功' if success else '失败'}")
        if success:
            # 获取模型信息
            info = model_loader.get_model_info()
            print(f"模型信息: {info}")
            
            # 进行预测测试（如果有测试图片）
            # results = model_loader.predict("path/to/test/image.jpg")
    
    def on_error(msg):
        print(f"错误: {msg}")
    
    model_loader.model_loaded.connect(on_model_loaded)
    model_loader.error_occurred.connect(on_error)
    
    # 加载模型
    model_loader.load_model()
    
    sys.exit(app.exec())