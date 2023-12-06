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

import { BusinessError } from '@ohos.base';
import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BreakpointSystem, BreakpointType, BreakpointTypeEnum, Logger, splashImages, UserAccount, WindowUtil } from '@ohos/common';
import { TopicModel } from '@ohos/topic';
import { UserModel } from '@ohos/mine';
import { DiscoverModel } from '@ohos/discover/src/main/ets/model/DiscoverModel';
import { SplashConstants, BgInfo } from '../constants/SplashConstants';
import { SplashSource } from '../viewmodel/SplashSource';

const TAG: string = '[SplashPage]';

@Entry
@Component
struct SplashPage {
  @State showSwiper: boolean = false;
  @State firstStart: boolean = true;
  private data: SplashSource = new SplashSource();
  private swiperController: SwiperController = new SwiperController();
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private userModel: UserModel = UserModel.getInstance();
  private topicModel: TopicModel = TopicModel.getInstance();
  private discoverModel: DiscoverModel = DiscoverModel.getInstance();
  private current_swiper: BgInfo = {
    time: 'day',
    index: 0
  };
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  onPageShow() {
    WindowUtil.updateStatusBarColor(getContext(this), true);
    let isAgreedPrivacy: boolean = router.getParams() ? (router.getParams() as Record<string, boolean>)['isAgreedPrivacy'] : false;
    if (isAgreedPrivacy) {
      let preferences: Promise<preferences.Preferences> = this.getDataPreferences();
      preferences.then((result: preferences.Preferences) => {
        Logger.info(TAG, 'isAgreedPrivacy.');
        let firstStartPut = result.put('isAgreedPrivacy', true);
        result.flush();
        firstStartPut.then(() => {
          Logger.info(TAG, 'Put the value of isAgreedPrivacy Successfully.');
          this.init();
        }).catch((err: BusinessError) => {
          Logger.error(TAG, 'Put the value of isAgreedPrivacy Failed, err: ' + err);
        });
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Get the preferences Failed, err: ' + err);
      });
    }
  }

  onPageHide() {
    WindowUtil.updateStatusBarColor(getContext(this), false);
  }

  aboutToAppear(): void {
    this.breakpointSystem.register();
    let data: Resource[] = [];
    let hours = new Date().getHours();
    if (hours >= SplashConstants.MORNING_TIME && hours < SplashConstants.EVENING_TIME) {
      data = splashImages.day;
      this.current_swiper.time = 'day';
    } else if (hours >= SplashConstants.EVENING_TIME && hours <= SplashConstants.NIGHT_TIME) {
      data = splashImages.dusk;
      this.current_swiper.time = 'dusk';
    } else {
      data = splashImages.night;
      this.current_swiper.time = 'night';
    }
    this.data.setDataArray(data);

    this.checkAgreedPrivacy();
  }

  init(): void {
    this.LoadingResource();
    this.checkIsFirstStart();

    setTimeout(() => {
      if (this.firstStart) {
        this.showSwiper = true;
      } else {
        this.jump()
      }
    }, SplashConstants.SPLASH_DURATION);
  }

  checkAgreedPrivacy(): void {
    let preferences: Promise<preferences.Preferences> = this.getDataPreferences();
    preferences.then((result: preferences.Preferences) => {
      result.get('isAgreedPrivacy', false).then((value: preferences.ValueType) => {
        Logger.info(TAG, 'check isAgreedPrivacy Succeed, isSet: ' + value);
        if (value) {
          this.init();
        } else {
          router.pushUrl({ url: 'pages/SafePage' });
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'check isAgreedPrivacy Failed, err: ' + err);
      });
    })
  }

  LoadingResource(): void {
    // Wait 1s for dependent resource initialization to complete
    setTimeout(() => {
      this.userModel.getUserAccount().then((userAccount: UserAccount | null) => {
        AppStorage.setOrCreate('getHomeResource', true);
        if (userAccount) {
          AppStorage.setOrCreate('user', userAccount);
          this.userModel.getUserData();
          this.discoverModel.getHomeResources();
          this.topicModel.getTopics();
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `LoadingResource getUserAccount failed: ${err}`);
        AppStorage.setOrCreate('getHomeResource', true);
      });
    }, SplashConstants.LOADING_RESOURCE_DURATION);
  }

  jump(): void {
    let bundleName = (getContext(this) as common.UIAbilityContext).applicationInfo.name;
    this.userModel.getUserAccount().then((userAccount: UserAccount | null) => {
      if (userAccount === null) {
        router.replaceUrl({
          url: `@bundle:${bundleName}/login/ets/pages/LoginPage`,
          params: {
            current_swiper: this.current_swiper
          }
        });
        return;
      }
      AppStorage.setOrCreate('user', userAccount);
      AppStorage.setOrCreate('isLogged', true);
      this.checkThemeIsSet().then((isSet: boolean) => {
        if (isSet) {
          router.replaceUrl({
            url: `@bundle:${bundleName}/phone/ets/pages/MainPage`
          });
        } else {
          router.replaceUrl({
            url: `@bundle:${bundleName}/topic/ets/pages/ThemeSettingPage`,
            params: {
              firstTopic: true
            }
          });
        }
      }).catch(() => {
        router.replaceUrl({
          url: `@bundle:${bundleName}/phone/ets/pages/MainPage`
        });
      })
    }).catch((err: BusinessError) => {
      router.replaceUrl({
        url: `@bundle:${bundleName}/login/ets/pages/LoginPage`,
        params: {
          current_swiper: this.current_swiper
        }
      });
      Logger.error(TAG, `getUserAccount failed: ${err}`);
    });
  }

  checkThemeIsSet(): Promise<boolean> {
    let preferences: Promise<preferences.Preferences> = this.getDataPreferences();
    return new Promise((resolve, reject) => {
      preferences.then((result: preferences.Preferences) => {
        result.get('ThemeIsSet', false).then((value: preferences.ValueType) => {
          Logger.info(TAG, 'check themeIsSet Succeed, isSet: ' + value);
          resolve(value as boolean);
        }).catch((err: BusinessError) => {
          Logger.error(TAG, 'check themeIsSet Failed, err: ' + err);
          reject();
        });
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'Get the themeIsSet Failed, err: ' + err);
        reject();
      });
    });

  }

  getDataPreferences(): Promise<preferences.Preferences> {
    return preferences.getPreferences(this.context, 'myStore');
  }

  checkIsFirstStart(): void {
    let preferences: Promise<preferences.Preferences> = this.getDataPreferences();
    preferences.then((result: preferences.Preferences) => {
      result.has('isFirstStart').then((hasResult: boolean) => {
        if (hasResult) {
          Logger.info(TAG, 'Not first startup.');
          this.firstStart = false;
        } else {
          Logger.info(TAG, 'First startup.');
          let firstStartPut = result.put('isFirstStart', false);
          result.flush();
          firstStartPut.then(() => {
            Logger.info(TAG, 'Put the value of startup Successfully.');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, 'Put the value of startup Failed, err: ' + err);
          });
        }
      }).catch((err: BusinessError) => {
        Logger.error(TAG, 'check startup Failed, err: ' + err);
      });
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Get the preferences Failed, err: ' + err);
    });
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.swiperController) {
          LazyForEach(this.data, (item: Resource) => {
            Image(item)
              .width(SplashConstants.FULL_SIZE)
              .height(SplashConstants.FULL_SIZE)
              .objectFit(ImageFit.Cover)
          })
        }
        .cachedCount(this.data.totalCount() - 1)
        .visibility(this.showSwiper ? Visibility.Visible : Visibility.Hidden)
        .loop(true)
        .autoPlay(true)
        .indicator(this.currentBreakpoint !== BreakpointTypeEnum.LG ? Indicator.dot()
          .itemWidth($r('app.float.splash_swiper_indicator'))
          .itemHeight($r('app.float.splash_swiper_indicator'))
          .selectedItemWidth($r('app.float.splash_swiper_indicator'))
          .selectedItemHeight($r('app.float.splash_swiper_indicator'))
          .color(Color.Gray)
          .selectedColor(Color.White) : false)
        .displayArrow(this.currentBreakpoint === BreakpointTypeEnum.LG ? {
          showBackground: true,
          isSidebarMiddle: true,
          arrowColor: $r('app.color.color_white'),
          backgroundColor: $r('app.color.arrow_bg_white')
        } : false)
        .onChange((index: number) => {
          this.current_swiper.index = index;
        })
        .curve(Curve.Linear)

        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text($r('app.string.splash_button_title'))
            .fontFamily($r('app.string.topic_title_family_sub'))
            .fontColor($r('app.color.color_white'))
            .fontSize($r('app.float.splash_normal_text_size'))
            .fontWeight(SplashConstants.BUTTON_FONT_WEIGHT)
            .opacity(SplashConstants.BUTTON_TEXT_OPACITY)
        }
        .visibility(this.showSwiper ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor($r('app.color.backgroundColor'))
        .width(new BreakpointType<Length>({
          sm: '86.7%',
          md: '45%',
          lg: '31%'
        }).getValue(this.currentBreakpoint))
        .height($r('app.float.button_height'))
        .onClick(() => this.jump())
        .borderRadius($r('app.float.button_borderRadius'))
        .backdropBlur(SplashConstants.BUTTON_BLUR)
        .margin({ bottom: 64 })


        Column() {
          Column() {
            Image($r('app.media.ic_splash'))
              .width($r('app.float.image_width'))
              .aspectRatio(1)
              .objectFit(ImageFit.Contain)
              .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
                duration: SplashConstants.SPLASH_ICON_OPACITY_DURATION,
                curve: Curve.Ease
              }), TransitionEffect.OPACITY.animation({
                duration: 0
              })))
          }
          .width(this.currentBreakpoint === BreakpointTypeEnum.LG ? SplashConstants.PERCENT_67 : SplashConstants.FULL_SIZE)
          .aspectRatio(this.currentBreakpoint === BreakpointTypeEnum.SM ? 2 / 3 : 3 / 2)
          .backgroundImageSize({
            width: this.currentBreakpoint === BreakpointTypeEnum.SM ? '225%' : SplashConstants.FULL_SIZE,
            height: SplashConstants.FULL_SIZE
          })
          .backgroundImage($r('app.media.bg_splash'))
          .backgroundImagePosition(Alignment.Center)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text($r('app.string.splash_main_title'))
              .fontFamily($r('app.string.topic_title_family_sub'))
              .fontColor($r('app.color.color_white'))
              .fontSize($r('app.float.splash_title_text_size'))
              .fontWeight(SplashConstants.BUTTON_FONT_WEIGHT)

            Text($r('app.string.splash_sub_title'))
              .fontFamily($r('app.string.topic_title_family_sub'))
              .fontSize($r('app.float.splash_normal_text_size'))
              .fontColor($r('app.color.color_white'))
              .opacity(SplashConstants.TEXT_OPACITY)
              .fontWeight(SplashConstants.TEXT_FONT_WEIGHT)
              .margin({
                top: $r('app.float.test_margin')
              })
          }
          .transition(TransitionEffect.asymmetric(TransitionEffect.OPACITY.animation({
            duration: SplashConstants.SPLASH_OPACITY_DURATION,
            curve: Curve.Ease
          }), TransitionEffect.OPACITY.animation({
            duration: 0
          })))
        }
        .padding({ bottom: '17%', top: 24 })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('app.color.theme_blue_color'))
        .height('100%')
        .width('100%')
        .visibility(this.showSwiper ? Visibility.Hidden : Visibility.Visible)
      }
    }
    .height(SplashConstants.FULL_SIZE)
    .width(SplashConstants.FULL_SIZE)
  }
}