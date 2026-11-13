import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';

void main() {
  group('TitleCard', () {
    test('parses the API payload including genres and progress', () {
      final card = TitleCard.fromJson({
        'id': 'title-1',
        'slug': 'inception',
        'name': 'Inception',
        'kind': 'movie',
        'release_year': 2010,
        'maturity_rating': 'PG-13',
        'runtime_minutes': 148,
        'poster_path': '/static/posters/inception.jpg',
        'backdrop_path': '/static/backdrops/inception.jpg',
        'match_percent': 98,
        'badges': ['Top 10'],
        'genres': [
          {'slug': 'sci-fi', 'name': 'Sci-Fi'},
        ],
        'progress': {
          'position_seconds': 120,
          'duration_seconds': 600,
          'percent': 20,
          'completed': false,
        },
      });

      expect(card.id, 'title-1');
      expect(card.releaseYear, 2010);
      expect(card.genres.single.slug, 'sci-fi');
      expect(card.progress?.percent, 20);
      expect(card.progress?.completed, isFalse);
    });

    test('uses safe defaults for absent optional fields', () {
      final card = TitleCard.fromJson({
        'id': 'x',
        'slug': 'x',
        'name': 'X',
      });
      expect(card.kind, 'movie');
      expect(card.badges, isEmpty);
      expect(card.progress, isNull);
    });
  });

  test('TitleDetail parses seasons and episodes', () {
    final detail = TitleDetail.fromJson({
      'id': 't',
      'slug': 's',
      'name': 'Show',
      'kind': 'series',
      'in_watchlist': true,
      'seasons': [
        {
          'id': 'season-1',
          'number': 1,
          'name': 'Season 1',
          'episodes': [
            {
              'id': 'ep-1',
              'number': 1,
              'season_number': 1,
              'name': 'Pilot',
              'runtime_minutes': 50,
            },
          ],
        },
      ],
    });

    expect(detail.inWatchlist, isTrue);
    expect(detail.seasons.single.episodes.single.seasonNumber, 1);
    expect(detail.seasons.single.episodes.single.name, 'Pilot');
    expect(detail.offers, isEmpty);
  });

  test('TitleDetail parses one offer per content source', () {
    final detail = TitleDetail.fromJson({
      'id': 't',
      'slug': 's',
      'name': 'Movie',
      'offers': [
        {
          'title_id': 't',
          'source_id': 'src-a',
          'source_name': 'Alpha',
          'episode_count': 0,
          'selected': true,
        },
        {
          'title_id': 'u',
          'source_id': 'src-b',
          'source_name': 'Beta',
          'episode_count': 0,
          'selected': false,
        },
      ],
    });

    expect(detail.offers, hasLength(2));
    expect(detail.offers.first.sourceName, 'Alpha');
    expect(detail.offers.first.selected, isTrue);
    expect(detail.offers.last.titleId, 'u');
  });
}
