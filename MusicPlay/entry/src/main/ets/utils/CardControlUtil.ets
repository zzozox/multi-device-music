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

import { MediaService } from './MediaService';

export class CardControlUtil {
  /**
   * Control by message.
   *
   * @param {string} message ,{number} index.
   */
  controlByMessage(message: string, index: number): void {
    switch (message) {
      case 'play':
        if (MediaService.getInstance().getFirst()) {
          MediaService.getInstance().loadAssent(0)
        } else {
          MediaService.getInstance().play();
        }
        break;
      case 'pause':
        MediaService.getInstance().pause();
        break;
      case 'next':
        MediaService.getInstance().playNextAuto(true);
        break;
      case 'last':
        MediaService.getInstance().playPrevious();
        break;
      case 'index':
        MediaService.getInstance().loadAssent(index);
        break;
      default:
        break;
    }
  }
}

let controlMusicPlayUtil = new CardControlUtil();

export default controlMusicPlayUtil as CardControlUtil;