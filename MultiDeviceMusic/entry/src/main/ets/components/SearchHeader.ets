import router from '@ohos.router';
import resourceManager from '@ohos.resourceManager';

@Preview
@Component
export struct SearchHeader {
  private querryStr:string='输入进行搜索'
  build() {
    Row({space:10}){
      Text('个人中心')
        .onClick(()=>{
          router.pushUrl(
            {
              url:'pages/MyInfo'
            },
            router.RouterMode.Single,
            error=>{
              console.log(error.message)
            }
          )
        })
      Blank()
      TextInput({placeholder:this.querryStr})
        .onChange((value)=>{
          this.querryStr=value
        })
        .height(40)
        .width('50%')
      Button('搜索')
        .backgroundColor('#a7d5d8')
        .height(30)
        .onClick(()=>{
          router.pushUrl(
            {
              url:'pages/MusicSearch',
              params:{querryStr:this.querryStr}
            },
            router.RouterMode.Single,
            error=>{
              console.log(this.querryStr)
              console.log('路由错误',error.message)
            }
          )
        })
    }
  }
}