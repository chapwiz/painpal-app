package uk.ac.bham.cxl593.painpal.api.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "pain_entries")
public class PainEntryEntity {

    @Id
    @Column(nullable = false)
    private UUID id;

    @JsonIgnore
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private SessionEntity session;

    @Column(name = "timestamp", nullable = false)
    private Instant timestamp;

    @Convert(converter = PainScaleConverter.class)
    @Column(name = "scale", nullable = false)
    private PainScale scale;

    @Column(name = "score", nullable = false)
    private int score;

    @Column(name = "notes", nullable = false)
    private String notes;

    @Column(name = "transcript")
    private String transcript;

    @Column(name = "ai_summary")
    private String aiSummary;

    @Convert(converter = PainTrendConverter.class)
    @Column(name = "trend", nullable = false)
    private PainTrend trend;

    @Column(name = "duration_minutes", nullable = false)
    private int durationMinutes;

    // Postgres text[] columns (stored as text[] in DB, allow custom user-entered strings)
    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "locations", columnDefinition = "text[]", nullable = false)
    private List<String> locations = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "quality_words", columnDefinition = "text[]", nullable = false)
    private List<String> qualityWords = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "symptoms", columnDefinition = "text[]", nullable = false)
    private List<String> symptoms = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "triggers", columnDefinition = "text[]", nullable = false)
    private List<String> triggers = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "relievers", columnDefinition = "text[]", nullable = false)
    private List<String> relievers = new ArrayList<>();

    @Column(name = "is_deleted", nullable = false)
    private boolean isDeleted;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    protected PainEntryEntity() {}

    public PainEntryEntity(
            UUID id,
            SessionEntity session,
            Instant timestamp,
            PainScale scale,
            int score,
            String notes,
            String transcript,
            String aiSummary,
            PainTrend trend,
            int durationMinutes,
            List<String> locations,
            List<String> qualityWords,
            List<String> symptoms,
            List<String> triggers,
            List<String> relievers
    ) {
        this.id = id;
        this.session = session;
        this.timestamp = timestamp;
        this.scale = (scale == null) ? PainScale.WONG_BAKER : scale;
        this.score = score;
        this.notes = (notes == null) ? "" : notes;
        this.transcript = transcript;
        this.aiSummary = aiSummary;
        this.trend = (trend == null) ? PainTrend.SAME : trend;
        this.durationMinutes = durationMinutes;

        this.locations = (locations == null) ? new ArrayList<>() : new ArrayList<>(locations);
        this.qualityWords = (qualityWords == null) ? new ArrayList<>() : new ArrayList<>(qualityWords);
        this.symptoms = (symptoms == null) ? new ArrayList<>() : new ArrayList<>(symptoms);
        this.triggers = (triggers == null) ? new ArrayList<>() : new ArrayList<>(triggers);
        this.relievers = (relievers == null) ? new ArrayList<>() : new ArrayList<>(relievers);

        this.isDeleted = false;
        this.deletedAt = null;
    }

    public UUID getId() { return id; }
    public SessionEntity getSession() { return session; }
    public Instant getTimestamp() { return timestamp; }
    public PainScale getScale() { return scale; }
    public int getScore() { return score; }
    public String getNotes() { return notes; }
    public String getTranscript() { return transcript; }
    public String getAiSummary() { return aiSummary; }
    public PainTrend getTrend() { return trend; }
    public int getDurationMinutes() { return durationMinutes; }
    public List<String> getLocations() { return locations; }
    public List<String> getQualityWords() { return qualityWords; }
    public List<String> getSymptoms() { return symptoms; }
    public List<String> getTriggers() { return triggers; }
    public List<String> getRelievers() { return relievers; }
    public boolean isDeleted() { return isDeleted; }
    public Instant getDeletedAt() { return deletedAt; }

    public void softDelete(Instant at) {
        this.isDeleted = true;
        this.deletedAt = at;
    }

    public void restore() {
        this.isDeleted = false;
        this.deletedAt = null;
    }


    public enum PainScale {
        WONG_BAKER("Wong-Baker"),
        R_FLACC("r-FLACC");

        private final String dbValue;

        PainScale(String dbValue) {
            this.dbValue = dbValue;
        }

        public String getDbValue() {
            return dbValue;
        }

        public static PainScale fromDbValue(String value) {
            if (value == null) return null;
            for (PainScale v : values()) {
                if (v.dbValue.equals(value)) return v;
            }
            throw new IllegalArgumentException("Unknown PainScale db value: " + value);
        }
    }

    public enum PainTrend {
        BETTER("Better"),
        SAME("Same"),
        WORSE("Worse");

        private final String dbValue;

        PainTrend(String dbValue) {
            this.dbValue = dbValue;
        }

        public String getDbValue() {
            return dbValue;
        }

        public static PainTrend fromDbValue(String value) {
            if (value == null) return null;
            for (PainTrend v : values()) {
                if (v.dbValue.equals(value)) return v;
            }
            throw new IllegalArgumentException("Unknown PainTrend db value: " + value);
        }
    }

    @Converter(autoApply = false)
    public static class PainScaleConverter implements AttributeConverter<PainScale, String> {
        @Override
        public String convertToDatabaseColumn(PainScale attribute) {
            return attribute == null ? null : attribute.getDbValue();
        }

        @Override
        public PainScale convertToEntityAttribute(String dbData) {
            return PainScale.fromDbValue(dbData);
        }
    }

    @Converter(autoApply = false)
    public static class PainTrendConverter implements AttributeConverter<PainTrend, String> {
        @Override
        public String convertToDatabaseColumn(PainTrend attribute) {
            return attribute == null ? null : attribute.getDbValue();
        }

        @Override
        public PainTrend convertToEntityAttribute(String dbData) {
            return PainTrend.fromDbValue(dbData);
        }
    }


}