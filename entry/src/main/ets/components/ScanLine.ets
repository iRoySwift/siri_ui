import { Animator, AnimatorOptions, AnimatorResult, curves } from "@kit.ArkUI";

let options: AnimatorOptions = {
  duration: 2000,
  easing: 'smooth',
  delay: 0,
  fill: 'none',
  direction: 'alternate',
  iterations: -1,
  begin: 0,
  end: 100
};

@Component
export struct ScanLine {
  @State linePosition: number = 0;
  @State allAngle: number = 180;
  @State reverse: boolean = false;
  @State speed: number = 0.0;
  @State isScanMotion: boolean = true;
  private backAnimator: AnimatorResult | undefined = Animator.create(options)
  private particlePropertyAnimationDown: ParticlePropertyAnimation<number> = {
    from: 0,
    to: 0.5,
    startMillis: 0,
    endMillis: 200,
    curve: Curve.Smooth
  }
  private particlePropertyAnimationUp: ParticlePropertyAnimation<number> = {
    from: 0.5,
    to: 0,
    startMillis: 300,
    endMillis: 500,
    curve: Curve.Smooth
  }
  private emitterOptions: EmitterOptions<ParticleType.POINT> = {
    particle: {
      type: ParticleType.POINT,
      config: {
        radius: 2
      },
      count: -1,
      lifetime: 500
    },
    size: ['100%', '100%'],
    emitRate: 60,
    shape: ParticleEmitterShape.RECTANGLE
  }

  async aboutToAppear() {
    try {
      await this.backAnimatorCreate();
      if (this.backAnimator) {
        this.backAnimator.play();
      }
    } catch (error) {
      console.log(`Failed to play backAnimator. Code: ${error.code}`);
    }
  }

  aboutToDisappear() {
    if (this.backAnimator) {
      this.backAnimator.cancel();
    }
    this.backAnimator = undefined;
  }

  async backAnimatorCreate(): Promise<void> {
    if (this.backAnimator) {
      this.backAnimator.onRepeat = () => {
        this.reverse = !this.reverse
        if (this.reverse) {
          this.allAngle = 0
        } else {
          this.allAngle = 180
        }
      }
      this.backAnimator.onCancel = () => {
      }
      this.backAnimator.onFrame = (value: number) => {

        this.linePosition = value;
        value = value / 100;
        if (value < 0.389) {
          this.speed = curves.cubicBezierCurve(0.4, 0.0, 0.7, 1.0).interpolate(value / 0.389);
        } else {
          this.speed = 1.0 - curves.cubicBezierCurve(0.25, 0.0, 0.4, 1.0).interpolate((value - 0.389) / 0.611);
        }
      }
    }
  }

  build() {
    Stack() {
      Image($rawfile('scan_line.png')).width('100%').height(2)
        .position({
          x: 0,
          y: this.linePosition + '%'
        })
      Image($rawfile('scan_shadow.png'))
        .width('100%')
        .height(130)
        .position({
          x: 0,
          y: this.linePosition + '%'
        })
        .scale({ y: Math.max(this.speed, 0.007) })
        .rotate({
          x: 1,
          angle: this.allAngle,
          centerX: 0,
          centerY: 0
        })

      Particle({
        particles: [
          {
            emitter: this.emitterOptions,
            scale: {
              range: [0.4, 1.1],
              updater: {
                type: ParticleUpdater.RANDOM,
                config: [
                  0.4, 1.1
                ]
              }
            },
            color: {
              range: ['#0A8BF5', '#FFFFFF']
            },
            opacity: {
              range: [0, 0.5],
              updater: {
                type: ParticleUpdater.CURVE,
                config: [
                  this.particlePropertyAnimationDown,
                  this.particlePropertyAnimationUp
                ]
              }
            }
          }
        ]
      }).width('80%')
        .height('100%')
        .markAnchor({ y: this.allAngle == 180 ? (60 * this.speed) : 0 })
        .maskShape(new Rect({ width: '100%', height: 60 * (this.speed) })
          .position({ y: this.linePosition + '%' })
          .fill(Color.White))
    }
    .width("100%")
    .height("100%")
  }
}