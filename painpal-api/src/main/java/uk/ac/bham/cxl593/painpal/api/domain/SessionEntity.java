package uk.ac.bham.cxl593.painpal.api.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "sessions")
public class SessionEntity {

    @Id
    private UUID id;

    @Column(name = "child_name", nullable = false)
    private String childName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "is_deleted", nullable = false)
    private boolean isDeleted;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    // Prevent infinite recursion when serializing Session -> entries -> session -> ...
    @JsonIgnore
    @OneToMany(mappedBy = "session", fetch = FetchType.LAZY)
    private List<PainEntryEntity> entries = new ArrayList<>();

    protected SessionEntity() {}

    public SessionEntity(UUID id, String childName, LocalDate dateOfBirth, Instant createdAt) {
        this.id = id;
        this.childName = childName;
        this.dateOfBirth = dateOfBirth;
        this.createdAt = createdAt;
        this.isDeleted = false;
        this.deletedAt = null;
    }

    public UUID getId() { return id; }
    public String getChildName() { return childName; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public Instant getCreatedAt() { return createdAt; }
    public boolean isDeleted() { return isDeleted; }
    public Instant getDeletedAt() { return deletedAt; }

    public List<PainEntryEntity> getEntries() { return entries; }
}