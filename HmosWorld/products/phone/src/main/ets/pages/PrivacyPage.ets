import router from '@ohos.router';
import { SplashConstants } from '../Constants/SplashConstants'
import webview from '@ohos.web.webview';

@Entry
@Component
struct PrivacyPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width($r('app.float.icon_back_size'))
          .height($r('app.float.icon_back_size'))
          .margin({ left: $r('app.float.icon_back_margin_left') })
          .onClick(() => {
            router.back();
          })
        Text($r('app.string.privacy_statement'))
          .fontSize($r('app.float.privacy_title_size'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: $r('app.float.privacy_title_margin_left') })
      }
      .height($r('app.float.privacy_title_height'))
      .width(SplashConstants.FULL_SIZE)

      GridRow({
        columns: {
          sm: SplashConstants.COLUMN_SM,
          md: SplashConstants.COLUMN_MD,
          lg: SplashConstants.COLUMN_LG
        },
        gutter: {
          x: {
            sm: $r('app.float.privacy_gutter'),
            md: $r('app.float.privacy_gutter'),
            lg: $r('app.float.privacy_gutter')
          }
        },
      }) {
        GridCol({
          span: {
            sm: SplashConstants.SPAN_SM,
            md: SplashConstants.SPAN_MD,
            lg: SplashConstants.SPAN_LG
          },
          offset: {
            sm: SplashConstants.OFFSET_SM,
            md: SplashConstants.OFFSET_MD,
            lg: SplashConstants.OFFSET_LG
          }
        }) {
          Column() {
            Web({ src: $rawfile('privacy-statement-zh-cn.htm'), controller: this.webViewController })
              .darkMode(WebDarkMode.Auto)
              .zoomAccess(true)
              .fileAccess(true)
              .mixedMode(MixedMode.All)
              .cacheMode(CacheMode.None)
              .javaScriptAccess(true)
              .domStorageAccess(true)
          }
          .width(SplashConstants.FULL_SIZE)
          .height(SplashConstants.FULL_SIZE)
        }
      }
    }
    .width(SplashConstants.FULL_SIZE)
    .height(SplashConstants.FULL_SIZE)
    .backgroundColor($r('app.color.common_background_color'))
    .padding({ top: AppStorage.get<number>('statusBarHeight'), bottom: $r('app.float.privacy_title_height') })
  }
}