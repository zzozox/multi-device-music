/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import taskpool from '@ohos.taskpool';
import { BreakpointTypeEnum } from '@ohos/common';
import { adjustOpacity } from '../utils/OpacityUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { AdjustId } from '../viewModel/OptionViewModel';
import { mergeArrayBuffers, splitArrayBuffer, splitTask } from '../utils/TaskUtil';

@Component
export struct SliderCustom {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @Prop currentIndex: number;
  @Link currentAdjustData: number[];
  @Prop min: number;
  @Prop max: number;
  @Consume pixelMap?: PixelMap;
  @Consume isPixelMapChange: boolean;
  private postState: boolean = true;
  saturationLastSlider: number = CommonConstants.SLIDER_MAX;
  brightnessLastSlider: number = CommonConstants.SLIDER_MAX;
  deviceListDialogController: CustomDialogController = new CustomDialogController({
    builder: Dialog(),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });

  build() {
    Flex({
      direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? FlexDirection.Row : FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Text(`${this.currentAdjustData[this.currentIndex]}`)
        .margin(this.currentBreakpoint === BreakpointTypeEnum.LG ? { left: $r('app.float.md_padding_margin') } : {
          top: $r('app.float.md_padding_margin')
        })
        .fontColor(Color.White)
        .fontSize($r('app.float.slider_font_size'))
      Slider({
        value: this.currentAdjustData[this.currentIndex],
        step: CommonConstants.SLIDER_STEP,
        min: this.min,
        max: this.max,
        direction: this.currentBreakpoint === BreakpointTypeEnum.LG ? Axis.Vertical : Axis.Horizontal,
        reverse: this.currentBreakpoint === BreakpointTypeEnum.LG
      })
        .selectedColor($r('app.color.hmos_main_blue_dark'))
        .trackColor(Color.White)
        .size(this.currentBreakpoint === BreakpointTypeEnum.LG ? { height: CommonConstants.SLIDER_WIDTH } : {
          width: CommonConstants.SLIDER_WIDTH
        })
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.sliderChange(value, mode);
        })
    }
  }

  sliderChange(value: number, mode: SliderChangeMode) {
    if (mode === SliderChangeMode.End) {
      this.currentAdjustData[this.currentIndex] = Math.round(value);
      switch (this.currentIndex) {
        case AdjustId.BRIGHTNESS:
          this.postProcess(AdjustId.BRIGHTNESS, value);
          break;
        case AdjustId.TRANSPARENCY:
          if (this.pixelMap) {
            adjustOpacity(this.pixelMap, Math.round(value))
              .then((pixelMap?: PixelMap) => {
                if (pixelMap) {
                  this.pixelMap = pixelMap;
                  this.isPixelMapChange = !this.isPixelMapChange;
                }
              });
          }
          break;
        case AdjustId.SATURATION:
          this.postProcess(AdjustId.SATURATION, value);
          break;
        default:
          break;
      }
    }
  }

  async postProcess(type: AdjustId, value: number) {
    if (!this.pixelMap) {
      return;
    }
    let sliderValue = type === AdjustId.BRIGHTNESS ? this.brightnessLastSlider : this.saturationLastSlider;
    const bufferArray = new ArrayBuffer(this.pixelMap.getPixelBytesNumber());
    this.pixelMap.readPixelsToBuffer(bufferArray).then(() => {

      const buffers: ArrayBuffer[] = splitArrayBuffer(bufferArray, CommonConstants.PIXEL_STEP);
      const group = splitTask(buffers, type, sliderValue, value)
      taskpool.execute(group, taskpool.Priority.HIGH).then((ret: ArrayBuffer[]) => {
        const entireArrayBuffer = mergeArrayBuffers(ret);
        this.updatePixelMap(entireArrayBuffer);
      })

      if (this.postState) {
        this.deviceListDialogController.open();
      }
      this.postState = false;
      if (type === AdjustId.BRIGHTNESS) {
        this.brightnessLastSlider = Math.round(value);
      } else {
        this.saturationLastSlider = Math.round(value);
      }

    });
  }

  updatePixelMap(ret: ArrayBuffer) {
    const newPixel = this.pixelMap as PixelMap;
    newPixel.writeBufferToPixels(ret);
    this.pixelMap = newPixel;
    this.isPixelMapChange = !this.isPixelMapChange;
    this.deviceListDialogController.close();
    this.postState = true;
  }
}

@CustomDialog
export struct Dialog {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  controller?: CustomDialogController;

  build() {
    Column() {
      LoadingProgress()
        .color(Color.White)
        .width(this.currentBreakpoint === BreakpointTypeEnum.LG ? $r('app.float.loading_size_lg') : $r('app.float.loading_size_lg'))
        .aspectRatio(1)
    }
  }
}