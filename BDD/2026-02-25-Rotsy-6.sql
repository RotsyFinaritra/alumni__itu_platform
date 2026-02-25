-- Trigger pour convertir edited_by = 0 en NULL (FK vers utilisateur)
-- Le type int Java initialise à 0 par défaut, ce qui viole la FK
CREATE OR REPLACE FUNCTION set_null_if_zero_edited_by()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.edited_by = 0 THEN
        NEW.edited_by := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_posts_edited_by_null
BEFORE INSERT OR UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION set_null_if_zero_edited_by();
