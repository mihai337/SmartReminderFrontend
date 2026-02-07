package triggers;

import java.time.Instant;

public class TimeTrigger extends Trigger {
    private Instant time;

    public TimeTrigger(Long id, boolean triggered, boolean onEnter, Instant time, String type) {
        super(id, triggered, onEnter, type);
        this.time = time;
    }

    public Instant getTime() {
        return time;
    }

    public void setTime(Instant time) {
        this.time = time;
    }
}
