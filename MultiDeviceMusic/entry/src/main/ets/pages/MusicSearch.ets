import router from '@ohos.router';
import { SongItem } from '../viewmodel/SongData';
import { SearchUtil } from '../common/utils/SearchUtil';
import { GridConstants } from '../common/constants/GridConstants';
import { StyleConstants } from '../common/constants/StyleConstants';
import { BreakpointSystem, BreakpointType } from '../common/utils/BreakpointSystem';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { MediaService } from '../common/utils/MediaService';
import { RouterUrlConstants } from '../common/constants/RouterUrlConstants';
import { Logger } from '../common/utils/Logger';
import { ContentConstants } from '../common/constants/ContentConstants';
import { SongDataSource } from '../viewmodel/SongDataSource';
import { Player } from '../components/Player';
import { recordSong } from '../common/constants/PlayRecord';


@Entry
@Component
struct MusicSearch {

  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @State currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  aboutToAppear() {
    MediaService.getInstance();
    this.breakpointSystem.register();
  }
  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }


  @Builder
  PlayAll() {
    Row() {
      Image($r('app.media.ic_play_all'))
        .height($r('app.float.play_all_icon_size'))
        .width($r('app.float.play_all_icon_size'))
      Text($r('app.string.play_all', this.songList.length))
        .maxLines(ContentConstants.PLAY_ALL_MAX_LINES)
        .padding({ left: $r('app.float.play_all_text_padding') })
        .fontColor(Color.Black)
        .fontSize(new BreakpointType({
          sm: $r('app.float.play_font_sm'),
          md: $r('app.float.play_font_md'),
          lg: $r('app.float.play_font_lg')
        }).getValue(this.currentBreakpoint))
      Blank()
      Image($r('app.media.ic_order_play'))
        .width($r('app.float.order_icon_size'))
        .height($r('app.float.order_icon_size'))
        .margin({ right: $r('app.float.order_icon_margin') })
      Image($r('app.media.ic_sort_list'))
        .height($r('app.float.order_icon_size'))
        .width($r('app.float.order_icon_size'))
    }
    .height($r('app.float.play_all_area_height'))
    .width(StyleConstants.FULL_WIDTH)
    .backgroundColor(Color.White)
    .padding({
      left: $r('app.float.play_all_area_padding'),
      right: $r('app.float.play_all_area_padding')
    })
    .borderRadius({
      topRight: $r('app.float.play_all_border_radius'),
      topLeft: $r('app.float.play_all_border_radius')
    })
    .position({ x: 0, y: 0 })
  }
  @Builder
  SongItem(item: SongItem, index?: number) {
    Row() {
      Column() {
        Text(item.title)
          .fontColor(Color.Black)
          .fontSize(new BreakpointType({
            sm: $r('app.float.item_font_sm'),
            md: $r('app.float.item_font_md'),
            lg: $r('app.float.item_font_lg')
          }).getValue(this.currentBreakpoint))
          .margin({ bottom: $r('app.float.list_item_title_margin') })
        Row() {
          Image(item.mark)
            .width($r('app.float.list_item_image_size'))
            .height($r('app.float.list_item_image_size'))
            .margin({ right: $r('app.float.list_item_image_margin') })
          Text(item.singer)
            .opacity($r('app.float.singer_opacity'))
            .fontColor(Color.Black)
            .fontSize(new BreakpointType({
              sm: $r('app.float.singer_title_sm'),
              md: $r('app.float.singer_title_md'),
              lg: $r('app.float.singer_title_lg')
            }).getValue(this.currentBreakpoint))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Image($r('app.media.ic_list_more'))
        .height($r('app.float.order_icon_size'))
        .width($r('app.float.order_icon_size'))
    }
    .onClick(() => {
      recordSong.push(item)
      MediaService.getInstance().loadAssent(index ? index : 0)
      router.pushUrl({
        url: RouterUrlConstants.MUSIC_PLAY
      }, router.RouterMode.Single)
        .catch((error: Error) => {
          Logger.error('pushUrl failed :' + JSON.stringify(error));
        })
    })
    .height($r('app.float.list_item_height'))
    .width(StyleConstants.FULL_WIDTH)
  }

  param:any=router.getParams()
  @State querryStr:string=this.param.querryStr
  @State songList:SongItem[]=SearchUtil.SearchSongs(this.querryStr);
  build() {
    Column(){
      //搜索导航栏
      Row({space:15}){
        Image($r('app.media.ic_back'))
          .width(30)
          .onClick(()=>{
            router.back()
          })
        Blank()
        Blank()
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
            router.replaceUrl(
              {
                url:'pages/MusicSearch',
                params:{querryStr:this.querryStr}
              },
              router.RouterMode.Single,
              error=>{
                console.log('路由错误',error.message)
              }
            )
          })
      }
      //搜索结果歌曲
      GridRow() {
        GridCol({ span: { sm: GridConstants.SPAN_TWELVE, md: GridConstants.SPAN_SIX, lg: GridConstants.SPAN_EIGHT } }) {
          Column() {
            this.PlayAll()
            List() {
              LazyForEach(new SongDataSource(this.songList), (item: SongItem, index?: number) => {
                ListItem() {
                  Column() {
                    this.SongItem(item, index)
                  }
                  .padding({
                    left: $r('app.float.list_item_padding'),
                    right: $r('app.float.list_item_padding')
                  })
                }
              }, (item: SongItem, index?: number) => JSON.stringify(item) + index)
            }
            .width(StyleConstants.FULL_WIDTH)
            .backgroundColor(Color.White)
            .margin({ top: $r('app.float.list_area_margin_top') })
            .lanes(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
            ContentConstants.COL_TWO : ContentConstants.COL_ONE)
            .layoutWeight(1)
            .divider({
              color: $r('app.color.list_divider'),
              strokeWidth: $r('app.float.stroke_width'),
              startMargin: $r('app.float.list_item_padding'),
              endMargin: $r('app.float.list_item_padding')
            })
          }
          .padding({
            top: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 0 : $r('app.float.list_area_padding_top'),
            bottom: $r('app.float.list_area_padding_bottom')
          })
        }
        .borderRadius($r('app.float.playlist_border_radius'))
      }
      .height(StyleConstants.FULL_HEIGHT)
      .onBreakpointChange((breakpoints: string) => {
        this.currentBreakpoint = breakpoints;
      })
      Player({ currentBreakpoint: $currentBreakpoint })
    }
  }
}