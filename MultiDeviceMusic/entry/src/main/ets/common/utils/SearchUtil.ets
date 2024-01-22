import { SongItem } from '../../viewmodel/SongData';
import { MusicList } from '../../viewmodel/MusicListViewModel'

export class SearchUtil {
   public static SearchSongs(keyword: string): SongItem[] {
    return MusicList.filter(song =>
    song.title.includes(keyword) || song.singer.includes(keyword)
    );
  }
}