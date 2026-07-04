import { window } from "@kit.ArkUI";
import { AppUtil } from "./AppUtil";

export class WindowUtil {
  /**
   * 获取当前应用窗口避让区
   */
  static getWindowAvoidArea(type: window.AvoidAreaType): window.AvoidArea {
    return AppUtil.getMainWindow().getWindowAvoidArea(type)
  }

  /**
   * 获取状态栏高度
   */
  static getTopAvoidRect(): window.AvoidArea {
    let top = WindowUtil.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM) // 状态栏区域
    return top;
  }

  /**
   * 获取底部导航区域高度
   */
  static getBottomAvoidRect(): window.AvoidArea {
    let bottom = WindowUtil.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) // 底部导航区域，单位vp
    return bottom;
  }

  /**
   * 获取当前窗口的属性
   */
  static getWindowProperties(): window.WindowProperties {
    return AppUtil.getMainWindow().getWindowProperties();
  }
}