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

import { Logger, ObservedArray, Topic, TopicsRepository, UserAccount } from '@ohos/common';

const TAG = '[TopicModel]';

export class TopicModel {
  public totalTopicList: ObservedArray<Topic> = new ObservedArray<Topic>();
  private resourceRepo: TopicsRepository = new TopicsRepository();
  private static instance: TopicModel;
  private constructor() {}

  public static getInstance(): TopicModel {
    if (!TopicModel.instance) {
      TopicModel.instance = new TopicModel();
    }
    return TopicModel.instance;
  }

  getTopics(): Promise<void> {
    const currentUser: UserAccount = AppStorage.get<UserAccount>('user') as UserAccount;
    return new Promise((resolve, reject) => {
      this.resourceRepo.getTopics(currentUser.id).then((topics: Topic[]) => {
        this.totalTopicList.length = 0;
        topics.forEach((topic: Topic) => {
          this.totalTopicList.push(new Topic(topic));
        })
        resolve();
      }).catch((err: Error) => {
        Logger.error(TAG, `Get topics failed! Error message is ${err}`);
        reject();
      });
    });
  }

  updateFollowedTopics(followedIds: string[]): Promise<void> {
    let currentUser: UserAccount = AppStorage.get<UserAccount>('user') as UserAccount;
    return new Promise((resolve, reject) => {
      this.resourceRepo.editTopicsFollowed(currentUser.id, followedIds.join(',')).then(() => {
        this.totalTopicList.forEach((topic: Topic) => {
          topic.isFollowed = followedIds.find((id: string) => id === topic.id) ? true : false;
        })
        resolve();
      }).catch((err: Error) => {
        Logger.error(TAG, `Update followed topics failed! Error message is ${err}`);
        reject();
      })
    })
  }
}