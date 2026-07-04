import { ScanUtil } from "@siri/utils";
import { AsyncCallback, BusinessError } from "@kit.BasicServicesKit";
import { scanBarcode } from "@kit.ScanKit";
import { promptAction } from "@kit.ArkUI";
import { ScanLine } from "./ScanLine";

@Component
export struct CustomScanCtrl {
  @Require @Prop userGrant: boolean = false;
  @Prop scanResult: Array<scanBarcode.ScanResult> = []
  @Prop scanBoxHeight: number = 0
  @Prop scanBoxWidth: number = 0
  @Prop offsetX: number = 0
  @Prop offsetY: number = 0
  @State isCameraLightOpen: boolean = false;
  @Prop isScanLine: boolean = false;
  bindLightingCall?: (callback: AsyncCallback<boolean, void> | undefined) => void

  aboutToAppear(): void {
    this.bindLightingCall?.(this.handleLighting)
  }

  aboutToDisappear(): void {
    this.isCameraLightOpen = false;
  }

  async handleLighting(err: BusinessError, isCameraLightOpen: boolean) {
    if (err) {
      return;
    }
    if (isCameraLightOpen) {
      this.isCameraLightOpen = true
    } else {
      this.isCameraLightOpen = false
    }
  }

  // toast显示扫码结果
  async showScanResult(result: scanBarcode.ScanResult) {
    // 使用toast显示出扫码结果
    promptAction.showToast({
      message: JSON.stringify(result),
      duration: 5000
    });
  }

  build() {
    Stack() {
      this.ScanLineBuilder()
      Column() {
        Blank()

        Row() {
          Image($rawfile("custom_scan_camera_light.svg"))
            .width($r("app.float.common_length_40"))
            .height($r("app.float.common_length_40"))
            .fillColor(this.isCameraLightOpen ? Color.Yellow : Color.White)
            .onClick(async () => {
              let lightStatus: boolean = await ScanUtil.csGetFlashLightStatus();

              // 根据当前闪光灯状态，选择打开或关闭闪关灯
              if (lightStatus) {
                ScanUtil.csCloseFlashLight()
              } else {
                ScanUtil.csOpenFlashLight()
              }
              this.isCameraLightOpen = !lightStatus
            })
            .visibility((this.userGrant) ? Visibility.Visible : Visibility.None)
        }
        .width("100%")
        .justifyContent(FlexAlign.Center)

        Blank().height("10%")
        this.CodeMarker()
      }
      .height("100%")

    }
    .width("100%")
    .height("100%")
  }

  @Builder
  ScanLineBuilder() {
    if (this.isScanLine) {
      Column() {
        ScanLine()
          .constraintSize({
            minHeight: 100
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(this.scanBoxHeight)
      .width(this.scanBoxWidth)
    }
  }

  @Builder
  CodeMarker() {
    // 单码、多码扫描后，显示码图蓝点位置。点击toast码图信息
    ForEach(this.scanResult, (item: scanBarcode.ScanResult, index: number) => {
      if (item.scanCodeRect) {
        Image($rawfile("scan_selected2.svg"))
          .width($r("app.float.common_length_40"))
          .height($r("app.float.common_length_40"))
          .markAnchor({ x: $r("app.float.common_space_20"), y: $r("app.float.common_space_20") })
          .position({
            x: (item.scanCodeRect.left + item?.scanCodeRect?.right) / 2 + this.offsetX,
            y: (item.scanCodeRect.top + item?.scanCodeRect?.bottom) / 2 + this.offsetY
          })
          .onClick(() => {
            this.showScanResult(item);
          })
      }
    })
  }
}
