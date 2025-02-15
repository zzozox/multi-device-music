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

import image from '@ohos.multimedia.image';
import resourceManager from '@ohos.resourceManager';
import { VideoItem } from './VideoItem';
import { VIDEO_DATA } from '../common/constants/CommonConstants';
import { GlobalContext } from '../common/util/GlobalContext';

export class HomeVideoListModel {
  private videoLocalList: Array<VideoItem> = [];
  private videoInternetList: Array<VideoItem> = [];

  /**
   * Scan the local video.
   *
   * @return Local video list data
   */
  async getLocalVideo() {
    this.videoLocalList = [];
    await this.assemblingVideoBean();
    GlobalContext.getContext().setObject('videoLocalList', this.videoLocalList);
    return this.videoLocalList;
  }

  /**
   * Assembling the video object
   */
  async assemblingVideoBean() {
    for (let index = 0; index < VIDEO_DATA.length; index++) {
      const element = VIDEO_DATA[index];
      let videoBean = await getContext().resourceManager.getRawFd(element.iSrc);
      let uri = videoBean;
      this.videoLocalList.push(new VideoItem(element.name, uri, ''));
    }
  }

  /**
   * Scan the internet video.
   *
   * @param name Video Name.
   * @param pixelMap pixelMap object.
   * @param src Playback Path.
   * @return Network video list data.
   */
  async setInternetVideo(name: string, src: string, pixelMap?: image.PixelMap) {
    this.videoInternetList.push(new VideoItem(name, {} as resourceManager.RawFileDescriptor, src, pixelMap));
    let videoInternetList = this.videoInternetList;
    GlobalContext.getContext().setObject('videoInternetList', videoInternetList);
    return videoInternetList;
  }
}

let homeVideoListModel = new HomeVideoListModel();

export default homeVideoListModel as HomeVideoListModel;