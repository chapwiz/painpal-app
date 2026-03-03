package uk.ac.bham.cxl593.painpal.api.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import uk.ac.bham.cxl593.painpal.api.domain.PainEntryEntity;

import java.util.List;
import java.util.UUID;

public interface PainEntryRepository extends JpaRepository<PainEntryEntity, UUID> {
    List<PainEntryEntity> findBySession_Id(UUID sessionId);
}