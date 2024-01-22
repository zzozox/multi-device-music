import router from '@ohos.router';
import {myInfo} from '../common/constants/MyInfo';

@Entry
@Component
struct EditMyInfo {
  build() {
    Column(){
      Row({ space: 10 }) {
        Image($r('app.media.ic_back'))
          .onClick(() => {
            router.back()
          })
          .width(30)
        Blank()
        Text('修改个人信息')
          .fontSize(24)
        Blank()
        Blank()
      }
      .height(60)
      .width('100%')
      Column(){
        Image(myInfo.image)
          .borderRadius(20)
          .width('70%')
        Blank(30)
        Row(){
          Text('请输入姓名')
          TextInput({placeholder:myInfo.name})
            .width('50%')
            .onChange((value)=>{
              myInfo.name=value;
            })
        }
        Blank(5)
        Row(){
          Text('请输入密码')
          TextInput({placeholder:myInfo.password})
            .width('50%')
            .onChange((value)=>{
              myInfo.password=value;
            })
        }
        Blank(5)
        Row(){
          Text('请输入性别')
          TextInput({placeholder:myInfo.sex})
            .width('50%')
            .onChange((value)=>{
              myInfo.sex=value;
            })
        }
        Blank(5)
        Row(){
          Text('请输入年龄')
          TextInput({placeholder:myInfo.age.toString()})
            .width('50%')
            .onChange((value)=>{
              myInfo.age=parseInt(value);
            })
        }
      }
      .layoutWeight(1)
      .width('100%')
      Blank().layoutWeight(1)
      Button('提交')
        .width('60%')
        .height(40)
        .backgroundColor('#a7d5d8')
        .onClick(()=>{
          router.replaceUrl(
            {
              url: 'pages/MyInfo',
            },
            router.RouterMode.Single,
            error => {
              console.log(error.message)
            }
          )
        })
      Blank().layoutWeight(1)
    }
  }
}