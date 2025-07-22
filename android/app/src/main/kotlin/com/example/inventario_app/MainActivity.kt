package com.example.inventario_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.inventario_app/scanner"
    private val SCAN_ACTION = "com.android.scanner.broadcast"
    private val SCAN_EXTRA = "scandata"
    private var scanReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        scanReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == SCAN_ACTION) {
                    val barcode = intent.getStringExtra(SCAN_EXTRA)
                    if (barcode != null) {
                        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("onBarcodeScanned", barcode)
                    }
                }
            }
        }
        val filter = IntentFilter(SCAN_ACTION)
        registerReceiver(scanReceiver, filter)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startScan") {
                // Si quieres iniciar el escaneo programáticamente, usa el SDK aquí
                result.success("Scan started")
            } else if (call.method == "stopScan") {
                result.success("Scan stopped")
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (scanReceiver != null) {
            unregisterReceiver(scanReceiver)
        }
    }
}