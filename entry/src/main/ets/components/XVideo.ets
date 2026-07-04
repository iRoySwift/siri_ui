import { Logger } from "@siri/utils"

const TAG = '[AvPlayer]'

@Component
export struct XVideo {
  @Link surfaceId: string
  private controller: XComponentController = new XComponentController()
  private compWidth: number = 0
  private compHeight: number = 0
  build() {
    Stack() {
      XComponent({
        id: "XComponent",
        type: XComponentType.SURFACE,
        controller: this.controller
      })
        .onLoad(async () => {
          this.controller.setXComponentSurfaceRect({
            surfaceWidth: this.compWidth,
            surfaceHeight: this.compHeight
          })

          this.surfaceId = this.controller.getXComponentSurfaceId()
          Logger.debug(TAG, `XComponent load success ${this.surfaceId}`)
        })
    }
    .onSizeChange((_, newSize) => {
      this.compWidth = newSize.width as number
      this.compHeight = newSize.height as number
    })
  }
}