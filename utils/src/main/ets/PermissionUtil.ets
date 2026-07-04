import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppUtil } from '../../../Index';
import { Logger } from './Logger';

const TAG: string = '[PermissionUtil]';

export class PermissionUtil {
  /**
   * 授权
   * @param permissions
   * @returns
   */
  static async requestPermissionsFromUser(permissions: Array<Permissions>): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      let grant = await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, permissions);
      let grantStatus: Array<number> = grant.authResults;
      for (let index = 0; index < grantStatus.length; index++) {
        if (grantStatus[index] !== 0) {
          return Promise.resolve(false)
        }
      }
      return Promise.resolve(true)
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `createBarcode failed code: ${err.code}, message: ${err.message}`)
      return Promise.resolve(false)
    }
  }

  /**
   * 二次授权
   * @param permissions
   * @returns
   */
  static async requestPermissionOnSetting(permissions: Array<Permissions>): Promise<boolean> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      let grantStatus = await atManager.requestPermissionOnSetting(getContext(), permissions)
      for (let index = 0; index < grantStatus.length; index++) {
        if (grantStatus[index] !== 0) {
          return Promise.resolve(false)
        }
      }
      return Promise.resolve(true)
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `createBarcode failed code: ${err.code}, message: ${err.message}`)
      return Promise.resolve(false)
    }
  }

  /**
   * 检查授权
   * @param permissions
   * @returns
   */
  static async checkPermissions(permissions: Array<Permissions>): Promise<boolean> {
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil.checkPermissionGrant(permission);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true;
      }
    }
    return false;
  }



  private static async checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }
}