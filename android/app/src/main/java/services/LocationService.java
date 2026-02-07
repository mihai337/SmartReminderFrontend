package services;

import android.Manifest;
import android.app.*;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.IBinder;
import android.os.Looper;

import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import com.google.android.gms.location.*;
import com.MSA.SmartReminderApp.R;

import java.util.ArrayList;
import java.util.List;

import models.TaskModel;

public class LocationService extends Service {

    private FusedLocationProviderClient fusedClient;
    private LocationCallback callback;

    private static final List<TaskModel> tasks = new ArrayList<>();

    private static boolean isRunning = false;

    public static void updateTasks(List<TaskModel> newTasks) {
        tasks.clear();
        tasks.addAll(newTasks);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        isRunning = true;

        fusedClient = LocationServices.getFusedLocationProviderClient(this);
        startForeground(1, createNotification());

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            stopSelf();
            return;
        }

        LocationRequest request = new LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 5000)
                .setMinUpdateIntervalMillis(2000)
                .build();

        callback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult result) {
                for (Location loc : result.getLocations()) {
                    handleLocation(loc);
                }
            }
        };

        fusedClient.requestLocationUpdates(request, callback, Looper.getMainLooper());
    }

    private void handleLocation(Location loc) {
        // Compare with tasks
        for (TaskModel task : tasks) {
            if (task.getTrigger() == null || !(task.getTrigger() instanceof triggers.LocationTrigger)) {
                continue;
            }

            double taskLat = ((triggers.LocationTrigger) task.getTrigger()).getLatitude();
            double taskLng = ((triggers.LocationTrigger) task.getTrigger()).getLongitude();
            double distance = distanceBetween(loc.getLatitude(), loc.getLongitude(), taskLat, taskLng);

            if (distance < 50) {
                showNotification(task.getTitle(), task.getDescription());
            }
        }
    }

    private double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
        float[] results = new float[1];
        android.location.Location.distanceBetween(lat1, lon1, lat2, lon2, results);
        return results[0];
    }

    private Notification createNotification() {
        String channelId = "location_channel";

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    channelId,
                    "Location Tracking",
                    NotificationManager.IMPORTANCE_LOW
            );
            getSystemService(NotificationManager.class).createNotificationChannel(channel);
        }

        Intent stopIntent = new Intent(this, LocationService.class);
        stopIntent.setAction("STOP");
        PendingIntent stopPending = PendingIntent.getService(
                this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        return new NotificationCompat.Builder(this, channelId)
                .setContentTitle("Location Service")
                .setContentText("Tracking location in background")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setOngoing(true)
                .addAction(0, "Stop", stopPending)
                .build();
    }

    private void showNotification(String title, String text) {
        NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "location_channel")
                .setContentTitle(title)
                .setContentText(text)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH);

        manager.notify((int) System.currentTimeMillis(), builder.build());
    }

    @Override
    public void onDestroy() {
        fusedClient.removeLocationUpdates(callback);
        isRunning = false;
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && "STOP".equals(intent.getAction())) {
            stopSelf();
        }
        return START_STICKY;
    }

    public static boolean isRunning() {
        return isRunning;
    }
}