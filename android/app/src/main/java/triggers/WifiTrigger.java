package triggers;

public class WifiTrigger extends Trigger {

    private String ssid;


    public String getSsid() {
        return ssid;
    }

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public WifiTrigger(Long id, boolean triggered, boolean onEnter, String ssid, String type) {
        super(id, triggered, onEnter, type);
        this.ssid = ssid;
    }
}
