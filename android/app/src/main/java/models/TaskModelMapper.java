package models;

import java.time.Instant;
import java.util.Map;

import triggers.Trigger;
import triggers.LocationTrigger;
import triggers.TimeTrigger;
import triggers.WifiTrigger;

public class TaskModelMapper {

    public static TaskModel mapToTaskModel(Map<String, Object> map) {
        String title = (String) map.get("title");
        String description = (String) map.get("description");
        Integer id = map.get("id") instanceof Integer ? (Integer) map.get("id") : null;

        String statusStr = (String) map.get("status");
        TaskStatus status = TaskStatus.valueOf(statusStr);

        String profileStr = (String) map.get("profile");
        TaskProfile profile = TaskProfile.valueOf(profileStr);

        Trigger trigger = mapToTrigger((Map<String, Object>) map.get("trigger"));

        return new TaskModel(description, title, id, status, profile, trigger);
    }

    private static Trigger mapToTrigger(Map<String, Object> triggerMap) {
        if (triggerMap == null) {
            return null;
        }

        String type = (String) triggerMap.get("type");
        Long id = triggerMap.get("id") instanceof Long ? (Long) triggerMap.get("id") :
                  (triggerMap.get("id") instanceof Integer ? ((Integer) triggerMap.get("id")).longValue() : null);
        boolean triggered = (boolean) triggerMap.get("triggered");
        boolean onEnter = (boolean) triggerMap.get("onEnter");

        switch (type) {
            case "LOCATION":
                Double latitude = ((Number) triggerMap.get("latitude")).doubleValue();
                Double longitude = ((Number) triggerMap.get("longitude")).doubleValue();
                Double radius = ((Number) triggerMap.get("radius")).doubleValue();
                return new LocationTrigger(id, triggered, onEnter, latitude, longitude, radius, type);

            case "TIME":
                Long timeMillis = ((Number) triggerMap.get("time")).longValue();
                Instant time = Instant.ofEpochMilli(timeMillis);
                return new TimeTrigger(id, triggered, onEnter, time, type);

            case "WIFI":
                String ssid = (String) triggerMap.get("ssid");
                return new WifiTrigger(id, triggered, onEnter, ssid, type);

            default:
                return null;
        }
    }
}

