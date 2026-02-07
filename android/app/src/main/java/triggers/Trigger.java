package triggers;

public abstract class Trigger {

    protected Long id;
    protected boolean triggered;
    protected boolean onEnter;

    protected String type;

    public Trigger(Long id, boolean triggered, boolean onEnter, String type) {
        this.id = id;
        this.triggered = triggered;
        this.onEnter = onEnter;
        this.type = type;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public boolean isTriggered() {
        return triggered;
    }

    public void setTriggered(boolean triggered) {
        this.triggered = triggered;
    }

    public boolean isOnEnter() {
        return onEnter;
    }

    public void setOnEnter(boolean onEnter) {
        this.onEnter = onEnter;
    }
}
