/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import { CardItemInterface, BreakpointConstants as Breakpoint, CommonConstants as BaseCommon } from '@ohos/base';
import { CardItem } from '../viewmodel/CardViewModel';

const MAX_GRID_COLUMN: number = 3;

const GRID_COLUMNS_TEMPLATE: string = '1fr 1fr 1fr';

@Component
export struct MircoBlogView {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = Breakpoint.BREAKPOINT_LG;
  @StorageLink('isDetailPage') isDetailPage: boolean = false;
  @State index: number = 0;
  @State cardItem: CardItem = new CardItem({} as CardItemInterface, 0);
  @State showPicture?: boolean = true;
  jumpDetail: () => void = () => {
  };

  jump(index: number) {
    AppStorage.setOrCreate('selectCardIndex', this.index);
    if (this.isDetailPage) {
      router.replaceUrl({
        url: BaseCommon.PICTURE_DETAIL_PATH,
        params: {
          index: index
        }
      });
    } else {
      router.pushUrl({
        url: BaseCommon.PICTURE_DETAIL_PATH,
        params: {
          index: index
        }
      });
    }
  }

  build() {
    Column() {
      if (this.cardItem !== undefined) {
        Row() {
          Row() {
            Image(this.cardItem.icon)
              .width($r('app.float.blog_icon_width'))
              .aspectRatio(1)
              .borderRadius($r('app.float.blog_icon_br'))

            Column() {
              Text(this.cardItem.name)
                .fontSize($r('app.float.blog_name_fs'))
                .fontWeight(BaseCommon.FONT_WEIGHT_500)
                .height($r('app.float.blog_name_height'))

              Text(this.cardItem.authorType)
                .fontWeight(FontWeight.Normal)
                .fontSize($r('app.float.author_type_fs'))
                .fontColor($r('app.color.author_type_color'))
                .height($r('app.float.author_type_height'))
            }
            .margin({ left: $r('app.float.blog_title_ml') })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .justifyContent(FlexAlign.Start)

          Row() {
            Image($r('app.media.ic_public_add'))
              .width($r('app.float.blog_add_width'))
              .aspectRatio(1)

            Text($r('app.string.blog_follow'))
              .fontSize($r('app.float.follow_font_size'))
              .fontColor($r('app.color.follow_font_color'))
              .margin({ left: $r('app.float.follow_margin_left') })
          }
          .borderRadius($r('app.float.blog_title_follow_br'))
          .backgroundColor($r('app.color.replay_bgc'))
          .padding({
            left: $r('app.float.blog_title_padding_left'),
            right: $r('app.float.blog_title_padding_left')
          })
          .width($r('app.float.blog_title_follow_width'))
          .height($r('app.float.blog_title_follow_height'))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(BaseCommon.FULL_PERCENT)
        .padding({
          top: $r('app.float.card_title_padding'),
          bottom: $r('app.float.card_title_padding')
        })

        Text(this.cardItem.content)
          .fontSize($r('app.float.comment_font_size'))
          .lineHeight($r('app.float.comment_line_height'))
          .width(BaseCommon.FULL_PERCENT)
          .onClick(() => {
            this.jumpDetail();
          })

        if (this.showPicture) {
          Grid() {
            ForEach(this.cardItem.pictureArray, (item: Resource, index: number) => {
              GridItem() {
                Image(item)
                  .width(BaseCommon.FULL_PERCENT)
                  .aspectRatio(1)
                  .onClick(() => {
                    this.jump(index);
                  })
              }
            }, (item: Resource, index: number) => index + JSON.stringify(item))
          }
          .columnsTemplate(GRID_COLUMNS_TEMPLATE)
          .columnsGap($r('app.float.grid_gap'))
          .rowsGap($r('app.float.grid_gap'))
          .width(BaseCommon.FULL_PERCENT)
          .aspectRatio(this.getAspectRatio(this.cardItem.pictureArray.length))
          .margin({ top: $r('app.float.picture_are_margin_top') })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
    .flexShrink(1)
    .width(BaseCommon.FULL_PERCENT)
  }

  getAspectRatio(length: number): number {
    let rowNumber: number = length % MAX_GRID_COLUMN === 0 ? length / MAX_GRID_COLUMN :
      (Math.floor(length / MAX_GRID_COLUMN) + 1);
    return MAX_GRID_COLUMN / rowNumber;
  }
}