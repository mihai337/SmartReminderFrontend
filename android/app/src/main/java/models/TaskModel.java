package models;

import java.util.Optional;

import triggers.Trigger;

public class TaskModel {
    private Optional<Integer> id;
    private String title;
    private String description;
    final TaskStatus status;
    final TaskProfile profile;
    final Trigger trigger;

    public TaskModel(String description, String title, Integer id, TaskStatus status, TaskProfile profile, Trigger trigger) {
        this.description = description;
        this.title = title;
        this.id = Optional.of(id);
        this.status = status;
        this.profile = profile;
        this.trigger = trigger;
    }

    public Optional<Integer> getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = Optional.ofNullable(id);
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public TaskStatus getStatus() {
        return status;
    }

    public TaskProfile getProfile() {
        return profile;
    }

    public Trigger getTrigger() {
        return trigger;
    }
}
