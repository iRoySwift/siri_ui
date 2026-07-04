import { common, StartOptions, Want } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { bundleManager } from "@kit.AbilityKit";

export class AppUtil {
  private static content : common.UIAbilityContext
  public static bundleName: string = ""
  // 定义私有静态常量，存储不同设置页面的URI
  static readonly uri_info: string = 'application_info_entry'; // 应用设置页面的URI
  static readonly uri_network: string = "mobile_network_entry"; // 移动网络设置页面的URI
  static readonly uri_notification: string = "systemui_notification_settings"; // 通知设置页面的URI
  static readonly uri_bluetooth: string = "bluetooth_entry"; // 蓝牙设置页面的URI
  static readonly uri_nfc: string = "nfc_settings"; // NFC设置页面的URI


  static getBundleInfoForSelf(bundleFlags?: number) {
    if(!bundleFlags) {
      bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION
    }
    // let bundleFlags =
    //   bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
    return bundleManager.getBundleInfoForSelf(bundleFlags)
  }

  /**
   * 获取主窗口
   */
  static getMainWindow(): window.Window {
    return AppUtil.getContext().windowStage.getMainWindowSync();
  }

  /**
   * 获取最上层 窗口
   * @returns
   */
  static async getLastWindow(): Promise<window.Window> {
    return await window.getLastWindow(getContext())
  }

  /**
   * 获取context 页面上下文 common.UIAbilityContex
   * @returns
   */
  static getContext():common.UIAbilityContext {
    if(!AppUtil.content) {
      AppUtil.content = getContext() as common.UIAbilityContext
    }
    return AppUtil.content;
  }

  /**
   * 获取UIContext
   * @returns
   */
  static getUIContext(): UIContext {
    return AppUtil.getMainWindow().getUIContext();
  }

  /**
   * 跳转应用设置页面（调用此方法到设置，手动开启权限）
   * @param uri 设置页面的URI，默认为应用设置页面的URI
   * @returns 返回一个Promise，该Promise解析为void
   */
  static async toAppSetting(uri: string = AppUtil.uri_info): Promise<void> {
    let context = AppUtil.getContext(); // 获取上下文信息
    // 创建Want对象，用于描述跳转意图
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings', // 设置应用bundleName
      abilityName: 'com.huawei.hmos.settings.MainAbility', // 设置应用abilityName
      uri: uri, // 目标页面URI
      parameters: {
        bundleName: context.abilityInfo.bundleName, // 拉起方应用包名
        pushParams: context.abilityInfo.bundleName, // 拉起方应用包名
      }
    }
    // 使用上下文信息启动设置应用
    return await context.startAbility(want);
  }

  /**
   * 跳转移动网络设置页面
   * @returns 返回一个Promise，该Promise解析为void
   */
  static toNetworkSetting(): Promise<void> {
    // 调用toAppSetting方法，传入移动网络设置页面的URI
    return AppUtil.toAppSetting(AppUtil.uri_network);
  }

  /**
   * 跳转通知设置页面
   * @returns 返回一个Promise，该Promise解析为void
   */
  static toNotificationSetting(): Promise<void> {
    // 调用toAppSetting方法，传入通知设置页面的URI
    return AppUtil.toAppSetting(AppUtil.uri_notification);
  }

  /**
   * 跳转蓝牙设置页面
   * @returns 返回一个Promise，该Promise解析为void
   */
  static toBluetoothSetting(): Promise<void> {
    // 调用toAppSetting方法，传入蓝牙设置页面的URI
    return AppUtil.toAppSetting(AppUtil.uri_bluetooth);
  }

  /**
   * 跳转NFC设置页面
   * @returns 返回一个Promise，该Promise解析为void
   */
  static toNfcSetting(): Promise<void> {
    // 调用toAppSetting方法，传入NFC设置页面的URI
    return AppUtil.toAppSetting(AppUtil.uri_nfc);
  }
}