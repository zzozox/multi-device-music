import router from '@ohos.router';
import { MusicList } from '../viewmodel/MusicListViewModel'
import { SongItem } from '../viewmodel/SongData'

@Entry
@Component
struct AddSong{
  index:number=MusicList.length
  newSong:SongItem=new SongItem()
  build(){
    Column(){
      Row({ space: 10 }) {
        Image($r('app.media.ic_back'))
          .onClick(() => {
            router.back()
          })
          .width(30)
        Blank()
        Text('上传歌曲')
          .fontSize(24)
        Blank()
        Blank()
      }
      .height(60)
      .width('100%')
      Column(){
        Image($r('app.media.ic_avatar8'))
          .borderRadius(20)
          .width('70%')
        Blank(30)
        Row(){
          Text('请输入歌名')
          TextInput({placeholder:'歌名'})
            .width('50%')
            .onChange((value)=>{
              this.newSong.title=value
            })
        }
        Blank(5)
        Row(){
          Text('请输入作者')
          TextInput({placeholder:'作者'})
            .width('50%')
            .onChange((value)=>{
              this.newSong.singer=value
            })
        }
        Blank(5)
        Row(){
          Text('请输入地址')
          TextInput({placeholder:'地址'})
            .width('50%')
            .onChange((value)=>{
              this.newSong.src=value+'.wav'
            })
        }
        Blank(5)
      }
      .layoutWeight(1)
      .width('100%')
      Blank().layoutWeight(1)
      Button('上传')
        .width('60%')
        .height(40)
        .backgroundColor('#a7d5d8')
        .onClick(()=>{
          router.replaceUrl(
            {
              url: 'pages/Index',
            },
            router.RouterMode.Single,
            error => {
              console.log(error.message)
            }
          )
          this.newSong.id=this.index+1
          this.newSong.mark=$r('app.media.ic_sq')
          this.newSong.label=$r('app.media.ic_avatar8')
          this.newSong.index=this.index
          MusicList.push(this.newSong)
        })
      Blank().layoutWeight(1)
    }
  }
}