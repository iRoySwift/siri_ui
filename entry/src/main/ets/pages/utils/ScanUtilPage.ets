import { Logger, PermissionUtil, ScanUtil, ToastUtil, WindowUtil } from '@siri/utils'
import { Permissions } from '@kit.AbilityKit';
import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { CustomScanCtrl } from '../../components/CustomScanCtrl';
import { XVideo } from '../../components/XVideo';
import { NavigationView } from '../../components/NavigationView';

const TAG: string = '[ScanUtilPage]';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.CAMERA'
];

@Entry
@Component
struct ScanUtilPage {
  @State userGrant: boolean = false // 是否已申请相机权限
  @State displayHeight: number = WindowUtil.getWindowProperties().windowRect.height; // 屏幕高度，单位vp
  @State displayWidth: number = WindowUtil.getWindowProperties().windowRect.width; // 屏幕宽度，单位vp
  @State cameraHeight: number = 0 // 设置预览流高度，默认单位：vp
  @State cameraWidth: number = 0 // 设置预览流宽度，默认单位：vp
  @State scanBoxWidth: number = WindowUtil.getWindowProperties().windowRect.height;
  @State scanBoxHeight: number = WindowUtil.getWindowProperties().windowRect.width;
  @State @Watch("onSurfaceId") surfaceId: string = '' // xComponent组件生成id
  @State isShowBack: boolean = false // 是否已经返回扫码结果
  @State isScanLine: boolean = false
  @State offsetX: number = 0 // 设置预览流x轴方向偏移量，默认单位：vp
  @State offsetY: number = 0 // 设置预览流y轴方向偏移量，默认单位：vp
  @State zoomValue: number = 1 // 预览流缩放比例
  @State setZoomValue: number = 1 // 已设置的预览流缩放比例
  @State scaleValue: number = 1 // 屏幕缩放比
  @State pinchValue: number = 1 // 双指缩放比例
  @State scanBox: scanBarcode.ScanCodeRect = {
    left: 0,
    top: 0,
    right: 0,
    bottom: 0
  }
  @State scanResult: Array<scanBarcode.ScanResult> = [] // 扫码结果
  // 相机闪光灯开启状态
  @State isCameraLightOpen: boolean = false;
  onLightingCall?: AsyncCallback<boolean, void> | undefined

  async aboutToAppear() {
    this.userGrant = await PermissionUtil.requestPermissionsFromUser(PERMISSIONS)
    await this.requestPermissionOnSetting()
  }

  async aboutToDisappear() {
    // 页面消失或隐藏时，停止并释放相机流
    this.userGrant = false;
    this.resetCamera()
  }

  /**
   * 二次授权
   * @param permissions
   * @returns
   */
  async requestPermissionOnSetting(): Promise<void> {
    if (!await PermissionUtil.checkPermissions(PERMISSIONS)) {
      if (!await PermissionUtil.requestPermissionOnSetting(PERMISSIONS)) {
        ToastUtil.showToast({
          message:"请在隐私和安全里面，打开图片和视频权限",
          duration: 2000
        })
        return;
      } else {
        this.userGrant = true
      }
    }
  }


  resetCamera() {
    ScanUtil.csOffLightingFlash()
    this.stopCamera();
    ScanUtil.csRelease()
  }

  async initCamera() {
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: false,
      enableAlbum: true
    };
    await ScanUtil.csInit(options)
  }

  // 竖屏时获取屏幕尺寸，设置预览流全屏示例
  setDisplay() {
    try {
      this.cameraHeight = this.displayHeight;
      this.cameraWidth = this.displayWidth
      // this.offsetX = (minLen - this.cameraWidth) / 2;
      this.scanBox = {
        left: (this.cameraWidth - this.scanBoxWidth) / 2,
        top: (this.cameraHeight - this.scanBoxHeight) / 2,
        right: (this.cameraWidth + this.scanBoxWidth) / 2,
        bottom: (this.cameraHeight + this.scanBoxHeight) / 2
      }
      console.log(`${this.scanBox}`)
    } catch (error) {
      Logger.error(TAG, `Failed to getDefaultDisplaySync. Code: ${error.code}, message: ${error.message}`);
    }
  }

  async startCamera() {
    this.isShowBack = false;
    this.scanResult = [];
    let viewControl: customScan.ViewControl = {
      width: this.cameraWidth,
      height: this.cameraHeight,
      surfaceId: this.surfaceId
    };
    ScanUtil.csStart(viewControl)
      .then(async (result: Array<scanBarcode.ScanResult>) => {
        // 扫描结果
        if (result.length) {
          let rect = result[0].scanCodeRect
          let scanResult: scanBarcode.ScanCodeRect = {
            left: rect?.left ?? 0,
            top: rect?.top ?? 0,
            right: rect?.right ?? 0,
            bottom: rect?.bottom ?? 0,
          };
          if (scanResult?.left >= this.scanBox.left && scanResult.top >= this.scanBox.top &&
            scanResult.right <= this.scanBox.right &&
            scanResult.bottom <= this.scanBox.bottom) {
            this.scanResult = result;
            this.isShowBack = true;
            // 获取到扫描结果后暂停相机流
            await this.stopCamera();
            // TODO:
          } else {
            await this.stopCamera();
            this.startCamera()
          }
        }
      });
    this.isScanLine = true;
  }

  async stopCamera() {
    await ScanUtil.csStop()
    this.isScanLine = false;
  }

  async onSurfaceId() {
    await this.startCamera()
    ScanUtil.csOnLightingFlash((err: BusinessError, isCameraLightOpen: boolean) => {
      this.onLightingCall?.(err, isCameraLightOpen)
    });
  }

  build() {
    Column() {
      NavigationView({
        leftView: () => {
        },
        title: "扫一扫工具",
        rightView: () => {
        }
      })
      Stack({ alignContent: Alignment.Top }) {
        if (this.userGrant) {
          XVideo({
            surfaceId: this.surfaceId
          })
        }

        CustomScanCtrl({
          userGrant: this.userGrant,
          scanResult: this.scanResult,
          isScanLine: this.isScanLine,
          scanBoxHeight: this.scanBoxHeight,
          scanBoxWidth: this.scanBoxWidth,
          offsetX: this.offsetX,
          offsetY: this.offsetY,
          bindLightingCall: (callback: AsyncCallback<boolean, void> | undefined) => {
            this.onLightingCall = callback
          }
        })

      }
      .width("100%")
      .height("100%")
      .onClick((event: ClickEvent) => {
        // 是否已扫描到结果
        if (this.isShowBack) {
          return;
        }
        // 点击屏幕位置，获取点击位置(x,y)，设置相机焦点
        let x1 = vp2px(event.displayY) / (this.displayHeight + 0.0);
        let y1 = 1.0 - (vp2px(event.displayX) / (this.displayWidth + 0.0));
        ScanUtil.csSetFocusPoint({ x: x1, y: y1 })

        // 设置连续自动对焦模式
        setTimeout(() => {
          ScanUtil.csResetFocus()
        }, 200);
      }).gesture(PinchGesture({ fingers: 2 })
        .onActionStart((event: GestureEvent) => {
          Logger.info(TAG, 'Pinch start');
        })
        .onActionUpdate((event: GestureEvent) => {
          if (event) {
            this.scaleValue = event.scale;
          }
        })
        .onActionEnd(async (event: GestureEvent) => {
          // 是否已扫描到结果
          if (this.isShowBack) {
            return;
          }
          // 获取双指缩放比例，设置变焦比
          let zoom = await ScanUtil.csGetZoom();
          this.pinchValue = this.scaleValue * zoom;
          ScanUtil.csSetZoom(this.pinchValue)
        }))
    }
    .width("100%")
    .height("100%")
  }
}