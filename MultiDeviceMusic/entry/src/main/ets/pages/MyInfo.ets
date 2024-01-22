import router from '@ohos.router';
import {myInfo} from '../common/constants/MyInfo'

@Entry
@Component
struct MyInfo {
  build() {
    Column() {
      Row({ space: 10 }) {
        Image($r('app.media.ic_back'))
          .onClick(() => {
            router.back()
          })
          .width(30)
        Blank()
        Text('个人信息')
          .fontSize(24)
        Blank()
        Button('修改')
          .backgroundColor('#a7d5d8')
          .height(40)
          .onClick(() => {
            router.replaceUrl(
              {
                url: 'pages/EditMyInfo',
              },
              router.RouterMode.Single,
              error => {
                console.log(error.message)
              }
            )
          })
      }
      .width('100%')
      .height(60)
      Column(){
        Image(myInfo.image)
          .borderRadius(20)
          .width('70%')
          .backgroundColor('#dee9eb')
        Blank(10)
        Text('姓名：'+myInfo.name)
          .height(30)
          .fontSize(20)
          .width('60%')
          .backgroundColor('#dee9eb')
        Blank(10)
        Text('密码：'+myInfo.password)
          .height(30)
          .fontSize(20)
          .width('60%')
          .backgroundColor('#dee9eb')
        Blank(10)
        Text('性别：'+myInfo.sex)
          .height(30)
          .fontSize(20)
          .width('60%')
          .backgroundColor('#dee9eb')
        Blank(10)
        Text('年龄：'+myInfo.age)
          .height(30)
          .fontSize(20)
          .width('60%')
          .backgroundColor('#dee9eb')
      }
    }
    .width('100%')
  }
}