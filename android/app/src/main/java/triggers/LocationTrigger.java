package triggers;

public class LocationTrigger extends Trigger{

    private Double latitude;
    private Double longitude;
    private Double radius;

    public LocationTrigger(Long id, boolean triggered, boolean onEnter, Double latitude, Double longitude, Double radius, String type) {
        super(id, triggered, onEnter, type);
        this.latitude = latitude;
        this.longitude = longitude;
        this.radius = radius;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getRadius() {
        return radius;
    }

    public void setRadius(Double radius) {
        this.radius = radius;
    }
}
