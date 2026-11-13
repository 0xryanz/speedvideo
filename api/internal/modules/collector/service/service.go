// Package service exposes the operations use cases over the collection queue:
// enqueueing work, retrying failures and reading job history. Jobs are executed
// by the separate collector process, never by the API.
package service

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/pagefau1t/speedvideo/api/internal/modules/collector/domain"
	"github.com/pagefau1t/speedvideo/api/internal/modules/collector/repository"
	"github.com/pagefau1t/speedvideo/api/internal/platform/apperr"
)

// Service owns queue rules.
type Service struct {
	repo *repository.Repository
}

// New builds the service.
func New(repo *repository.Repository) *Service {
	return &Service{repo: repo}
}

// EnqueueSync queues a full or incremental scan.
func (s *Service) EnqueueSync(ctx context.Context, sourceID, kind string) (*domain.Job, error) {
	if kind == "" {
		kind = domain.JobIncremental
	}
	if kind != domain.JobFull && kind != domain.JobIncremental {
		return nil, apperr.New(apperr.KindValidation, "kind must be full or incremental")
	}
	return s.repo.Enqueue(ctx, sourceID, kind, "", "")
}

// EnqueueTitleRefresh re-collects one catalogue title from the source that
// supplied it. The title id is preserved by the collector.
func (s *Service) EnqueueTitleRefresh(ctx context.Context, titleID string) (*domain.Job, error) {
	item, err := s.repo.ItemByTitleID(ctx, titleID)
	if err != nil {
		return nil, err
	}
	return s.repo.Enqueue(ctx, item.SourceID, domain.JobTitle, item.RemoteID, "")
}

// EnqueuePreview asks the collector to fetch one provider page without writing
// the catalogue. The console polls the job for its result.
func (s *Service) EnqueuePreview(
	ctx context.Context,
	sourceID, query string,
	page int,
) (*domain.Job, error) {
	if page < 1 {
		page = 1
	}
	payload, err := json.Marshal(map[string]any{
		"query": strings.TrimSpace(query),
		"page":  page,
	})
	if err != nil {
		return nil, apperr.New(apperr.KindValidation, "could not encode preview request")
	}
	return s.repo.Enqueue(ctx, sourceID, domain.JobPreview, "", string(payload))
}

// EnqueueTypeDiscovery asks the collector to read the provider's category list
// and cache it on the source. The console polls the job for its result.
func (s *Service) EnqueueTypeDiscovery(ctx context.Context, sourceID string) (*domain.Job, error) {
	return s.repo.Enqueue(ctx, sourceID, domain.JobTypes, "", "")
}

// GetJob loads one job.
func (s *Service) GetJob(ctx context.Context, id string) (*domain.Job, error) {
	return s.repo.GetJob(ctx, id)
}

// RetryJob re-queues a finished job.
func (s *Service) RetryJob(ctx context.Context, id string) (*domain.Job, error) {
	return s.repo.RetryJob(ctx, id)
}

// ListJobs lists jobs with paging.
func (s *Service) ListJobs(
	ctx context.Context,
	filter repository.Filter,
) ([]domain.Job, int64, error) {
	return s.repo.ListJobs(ctx, filter)
}

// ListRuns lists executions with paging.
func (s *Service) ListRuns(
	ctx context.Context,
	filter repository.RunFilter,
) ([]domain.Run, int64, error) {
	return s.repo.ListRuns(ctx, filter)
}

// ListItems lists collected provider entries with paging.
func (s *Service) ListItems(
	ctx context.Context,
	filter repository.ItemFilter,
) ([]repository.ItemRow, int64, error) {
	return s.repo.ListItems(ctx, filter)
}

// Stats returns the dashboard aggregates.
func (s *Service) Stats(ctx context.Context) (repository.Stats, error) {
	return s.repo.Stats(ctx)
}
