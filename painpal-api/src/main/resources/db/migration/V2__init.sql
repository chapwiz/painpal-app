CREATE TABLE sessions (
    id           UUID PRIMARY KEY,
    child_name   TEXT NOT NULL,
    date_of_birth DATE NULL,

    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    version       INTEGER NOT NULL DEFAULT 0,

    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMPTZ NULL
);

CREATE TABLE pain_entries (
    id              UUID PRIMARY KEY,

    session_id       UUID NOT NULL
        REFERENCES sessions(id)
        ON DELETE CASCADE,

    timestamp        TIMESTAMPTZ NOT NULL DEFAULT now(),

    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    version          INTEGER NOT NULL DEFAULT 0,

    -- enum-like values from Swift app
    scale            TEXT NOT NULL, -- "Wong-Baker" / "r-FLACC"
    score            INTEGER NOT NULL,
    notes            TEXT NOT NULL DEFAULT '',

    transcript       TEXT NULL,
    ai_summary       TEXT NULL,

    trend            TEXT NOT NULL DEFAULT 'Same', -- Better / Same / Worse
    duration_minutes INTEGER NOT NULL DEFAULT 0,

    -- multi-select fields from the app (stored as arrays)
    locations        TEXT[] NOT NULL DEFAULT '{}',
    quality_words    TEXT[] NOT NULL DEFAULT '{}',
    symptoms         TEXT[] NOT NULL DEFAULT '{}',
    triggers         TEXT[] NOT NULL DEFAULT '{}',
    relievers        TEXT[] NOT NULL DEFAULT '{}',

    is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at        TIMESTAMPTZ NULL,

    -- basic sanity constraints (feel free to adjust)
    CONSTRAINT chk_pain_entries_score CHECK (score >= 0 AND score <= 10),
    CONSTRAINT chk_pain_entries_duration CHECK (duration_minutes >= 0)
);

CREATE TRIGGER trg_pain_entries_updated
BEFORE UPDATE ON pain_entries
FOR EACH ROW EXECUTE FUNCTION set_updated_at_and_version();

-- Useful indexes for common queries
CREATE INDEX idx_sessions_created_at ON sessions(created_at DESC);
CREATE INDEX idx_sessions_updated_at   ON sessions(updated_at DESC);
CREATE INDEX idx_sessions_is_deleted ON sessions(is_deleted);

CREATE INDEX idx_pain_entries_session_id ON pain_entries(session_id);
CREATE INDEX idx_pain_entries_timestamp ON pain_entries(timestamp DESC);
CREATE INDEX idx_pain_entries_updated_at  ON pain_entries(updated_at DESC);
CREATE INDEX idx_pain_entries_is_deleted ON pain_entries(is_deleted);