Dispositivo
Marca: Samsung
Modelo: SM-S711B
Orientação: Retrato
Espaço livre na memória RAM: 2.2 GiB
Espaço livre no disco: 3.44 GiB
Sistema operacional
Versão:Android 15
Orientação: Retrato
Com acesso root: Não
Falha
Data: 28 de ago. de 2026, 18:30:57
Versão do app: 1.3.0 (10)
Usuário
Código:178

Fatal Exception: java.lang.UnsupportedOperationException: Tried to obtain display from a Context not associated with one. Only visual Contexts (such as Activity or one created with Context#createWindowContext) or ones created with Context#createDisplayContext are associated with displays. Other types of Contexts are typically related to background entities and may return an arbitrary display.
       at android.app.ContextImpl.getDisplay(ContextImpl.java:3236)
       at android.content.ContextWrapper.getDisplay(ContextWrapper.java:1217)
       at io.flutter.plugins.camerax.ProxyApiRegistrar.getDisplay(ProxyApiRegistrar.java:148)
       at io.flutter.plugins.camerax.DeviceOrientationManager.getDisplay(DeviceOrientationManager.java:198)
       at io.flutter.plugins.camerax.DeviceOrientationManager.getDefaultRotation(DeviceOrientationManager.java:185)
       at io.flutter.plugins.camerax.DeviceOrientationManager.getUiOrientation(DeviceOrientationManager.java:150)
       at io.flutter.plugins.camerax.DeviceOrientationManager.handleUiOrientationChange(DeviceOrientationManager.java:98)
       at io.flutter.plugins.camerax.DeviceOrientationManager$1.onOrientationChanged(DeviceOrientationManager.java:74)
       at android.view.OrientationEventListener$SensorEventListenerImpl.onSensorChanged(OrientationEventListener.java:223)
       at android.hardware.SystemSensorManager$SensorEventQueue.dispatchSensorEvent(SystemSensorManager.java:1181)
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.app.ActivityThread.main(ActivityThread.java:9634)
       at java.lang.reflect.Method.invoke(Method.java)
       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:619)
       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:929)

CameraX-scheduler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

pool-7-thread-9:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-camerax_high_priority:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-19-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraManagerGlobal:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

CameraX-camerax_io_0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-22:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

ReferenceQueueDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$ReferenceQueueDaemon.runInternal(Daemons.java:262)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

pool-5-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

DefaultDispatcher-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-21:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-23:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

pool-7-thread-12:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

flutter-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

InteractionJankMonitor-Worker:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

pool-7-thread-11:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerWatchdogDaemon:
       at java.lang.Thread.sleep(Thread.java)
       at java.lang.Thread.sleep0(Thread.java:689)
       at java.lang.Thread.sleep(Thread.java:667)
       at java.lang.Thread.sleep(Thread.java:580)
       at java.lang.Daemons$FinalizerWatchdogDaemon.sleepForNanos(Daemons.java:536)
       at java.lang.Daemons$FinalizerWatchdogDaemon.waitForProgress(Daemons.java:595)
       at java.lang.Daemons$FinalizerWatchdogDaemon.runInternal(Daemons.java:467)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-5:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

pool-7-thread-10:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-18:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_1:
       at android.os.BinderProxy.transactNative(BinderProxy.java)
       at android.os.BinderProxy.transact(BinderProxy.java:655)
       at android.hardware.camera2.ICameraDeviceUser$Stub$Proxy.disconnect(ICameraDeviceUser.java:600)
       at android.hardware.camera2.impl.ICameraDeviceUserWrapper.disconnect(ICameraDeviceUserWrapper.java:61)
       at android.hardware.camera2.impl.CameraDeviceImpl.close(CameraDeviceImpl.java:1562)
       at androidx.camera.camera2.internal.compat.ApiCompat$Api21Impl.close(ApiCompat.java:53)
       at androidx.camera.camera2.internal.Camera2CameraImpl$3.onSuccess(Camera2CameraImpl.java:743)
       at androidx.camera.camera2.internal.Camera2CameraImpl$3.onSuccess(Camera2CameraImpl.java:723)
       at androidx.camera.core.impl.utils.futures.Futures$CallbackListener.run(Futures.java:346)
       at androidx.camera.core.impl.utils.executor.DirectExecutor.execute(DirectExecutor.java:43)
       at androidx.concurrent.futures.AbstractResolvableFuture.executeListener(AbstractResolvableFuture.java:1056)
       at androidx.concurrent.futures.AbstractResolvableFuture.complete(AbstractResolvableFuture.java:905)
       at androidx.concurrent.futures.AbstractResolvableFuture.set(AbstractResolvableFuture.java:687)
       at androidx.concurrent.futures.CallbackToFutureAdapter$SafeFuture.set(CallbackToFutureAdapter.java:180)
       at androidx.concurrent.futures.CallbackToFutureAdapter$Completer.set(CallbackToFutureAdapter.java:249)
       at androidx.camera.camera2.internal.CaptureSession.finishClose(CaptureSession.java:653)
       at androidx.camera.camera2.internal.CaptureSession$StateCallback.onSessionFinished(CaptureSession.java:1190)
       at androidx.camera.camera2.internal.SynchronizedCaptureSessionStateCallbacks.onSessionFinished(SynchronizedCaptureSessionStateCallbacks.java:105)
       at androidx.camera.camera2.internal.SynchronizedCaptureSessionBaseImpl.lambda$onSessionFinished$4(SynchronizedCaptureSessionBaseImpl.java:581)
       at androidx.camera.core.impl.utils.executor.DirectExecutor.execute(DirectExecutor.java:43)
       at androidx.concurrent.futures.AbstractResolvableFuture.executeListener(AbstractResolvableFuture.java:1056)
       at androidx.concurrent.futures.AbstractResolvableFuture.addListener(AbstractResolvableFuture.java:668)
       at androidx.concurrent.futures.CallbackToFutureAdapter$SafeFuture.addListener(CallbackToFutureAdapter.java:210)
       at androidx.camera.camera2.internal.SynchronizedCaptureSessionBaseImpl.onSessionFinished(SynchronizedCaptureSessionBaseImpl.java:579)
       at androidx.camera.camera2.internal.SynchronizedCaptureSessionBaseImpl.lambda$close$2(SynchronizedCaptureSessionBaseImpl.java:475)
       at androidx.camera.core.impl.utils.executor.SequentialExecutor$QueueWorker.workOnQueue(SequentialExecutor.java:229)
       at androidx.camera.core.impl.utils.executor.SequentialExecutor$QueueWorker.run(SequentialExecutor.java:171)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:207)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:228)
       at java.lang.Daemons$FinalizerDaemon.runInternal(Daemons.java:350)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

MLHandler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

pool-12-thread-20:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

GoogleApiHandler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

FileObserver:
       at android.os.FileObserver$ObserverThread.observe(FileObserver.java)
       at android.os.FileObserver$ObserverThread.run(FileObserver.java:116)

CameraX-core_camera_3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-19:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

DefaultDispatcher-worker-6:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

Firebase Background Thread #2:
       at dalvik.system.VMStack.getThreadStackTrace(VMStack.java)
       at java.lang.Thread.getStackTrace(Thread.java:2852)
       at java.lang.Thread.getAllStackTraces(Thread.java:2919)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateThreadsList(CrashlyticsReportDataCapture.java:343)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateExecutionData(CrashlyticsReportDataCapture.java:314)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateEventApplicationData(CrashlyticsReportDataCapture.java:261)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.captureEventData(CrashlyticsReportDataCapture.java:112)
       at com.google.firebase.crashlytics.internal.common.SessionReportingCoordinator.persistEvent(SessionReportingCoordinator.java:371)
       at com.google.firebase.crashlytics.internal.common.SessionReportingCoordinator.persistFatalEvent(SessionReportingCoordinator.java:136)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsController$2.call(CrashlyticsController.java:234)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsController$2.call(CrashlyticsController.java:220)
       at com.google.firebase.crashlytics.internal.concurrency.CrashlyticsWorker.lambda$submitTask$2(CrashlyticsWorker.java:118)
       at com.google.android.gms.tasks.zze.run(zze.java:1)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

queued-work-looper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

DefaultDispatcher-worker-4:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

pool-12-thread-17:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Blocking Thread #5:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

Okio Watchdog:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at com.android.okhttp.okio.AsyncTimeout.awaitTimeout(AsyncTimeout.java:313)
       at com.android.okhttp.okio.AsyncTimeout.access$000(AsyncTimeout.java:42)
       at com.android.okhttp.okio.AsyncTimeout$Watchdog.run(AsyncTimeout.java:288)

SurfaceSyncGroupTimer:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:346)
       at android.os.Looper.loopOnce(Looper.java:214)
       at android.os.Looper.loop(Looper.java:342)
       at android.os.HandlerThread.run(HandlerThread.java:85)

Firebase Background Thread #0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

pool-12-thread-24:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:276)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:1803)
       at java.util.concurrent.LinkedBlockingQueue.poll(LinkedBlockingQueue.java:460)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.mlkit.common.sdkinternal.MlKitThreadPool.zzd(MlKitThreadPool.java:2)
       at com.google.mlkit.common.sdkinternal.zzk.run(zzk.java:18)
       at java.lang.Thread.run(Thread.java:1572)


Dispositivo
Marca: Samsung
Modelo: SM-A315G
Orientação: Retrato
Espaço livre na memória RAM: 1.26 GiB
Espaço livre no disco: 41.74 GiB
Sistema operacional
Versão:Android 12
Orientação: Retrato
Com acesso root: Não
Falha
Data: 27 de ago. de 2026, 20:08:34
Versão do app: 1.3.0 (10)
Usuário
Código:73


Fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: ClientException with SocketException: Read failed (OS Error: Connection reset by peer, errno = 104), address = app.coringaplus.com, port = 47390, uri=https://app.coringaplus.com/v1/plantoes/73/7
       at IOClient.send(io_client.dart:154)
       at BaseClient._sendUnstreamed(base_client.dart:93)
       at ._withClient(http.dart:167)
       at HttpService._send(http_service.dart:67)
       at PlantaoService.buscarPlantoesDoUsuario(plantao_service.dart:12)
       at PlantaoController.listarPlantoes(plantao_controller.dart:36)
       at PlantaoController.inicializar(plantao_controller.dart:59)
       at _SelfieCaptureScreenState._inicializarController(selfie_capture_screen.dart:331)

CameraX-scheduler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:335)
       at android.os.Looper.loopOnce(Looper.java:186)
       at android.os.Looper.loop(Looper.java:313)
       at android.os.HandlerThread.run(HandlerThread.java:67)

CameraX-core_camera_0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

flutter-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FileObserver:
       at android.os.FileObserver$ObserverThread.observe(FileObserver.java)
       at android.os.FileObserver$ObserverThread.run(FileObserver.java:116)

main:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:335)
       at android.os.Looper.loopOnce(Looper.java:186)
       at android.os.Looper.loop(Looper.java:313)
       at android.app.ActivityThread.main(ActivityThread.java:8663)
       at java.lang.reflect.Method.invoke(Method.java)
       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:571)
       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1135)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerWatchdogDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$FinalizerWatchdogDaemon.sleepUntilNeeded(Daemons.java:483)
       at java.lang.Daemons$FinalizerWatchdogDaemon.runInternal(Daemons.java:463)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

pool-6-thread-5:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

queued-work-looper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.next(MessageQueue.java:335)
       at android.os.Looper.loopOnce(Looper.java:186)
       at android.os.Looper.loop(Looper.java:313)
       at android.os.HandlerThread.run(HandlerThread.java:67)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

DefaultDispatcher-worker-4:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

ReferenceQueueDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$ReferenceQueueDaemon.runInternal(Daemons.java:262)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

Okio Watchdog:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at com.android.okhttp.okio.AsyncTimeout.awaitTimeout(AsyncTimeout.java:313)
       at com.android.okhttp.okio.AsyncTimeout.access$000(AsyncTimeout.java:42)
       at com.android.okhttp.okio.AsyncTimeout$Watchdog.run(AsyncTimeout.java:288)

CameraX-core_camera_2:
       at android.os.BinderProxy.transactNative(BinderProxy.java)
       at android.os.BinderProxy.transact(BinderProxy.java:635)
       at android.hardware.ICameraService$Stub$Proxy.connectDevice(ICameraService.java:775)
       at android.hardware.camera2.CameraManager.openCameraDeviceUserAsync(CameraManager.java:789)
       at android.hardware.camera2.CameraManager.openCameraForUid(CameraManager.java:1059)
       at android.hardware.camera2.CameraManager.openCameraForUid(CameraManager.java:1080)
       at android.hardware.camera2.CameraManager.openCamera(CameraManager.java:958)
       at androidx.camera.camera2.internal.compat.CameraManagerCompatApi29Impl.openCamera(CameraManagerCompatApi29Impl.java:45)
       at androidx.camera.camera2.internal.compat.CameraManagerCompat.openCamera(CameraManagerCompat.java:226)
       at androidx.camera.camera2.internal.Camera2CameraImpl.openCameraDevice(Camera2CameraImpl.java:1459)
       at androidx.camera.camera2.internal.Camera2CameraImpl.tryForceOpenCameraDevice(Camera2CameraImpl.java:1391)
       at androidx.camera.camera2.internal.Camera2CameraImpl.openInternal(Camera2CameraImpl.java:345)
       at androidx.camera.camera2.internal.Camera2CameraImpl.tryAttachUseCases(Camera2CameraImpl.java:1002)
       at androidx.camera.camera2.internal.Camera2CameraImpl.lambda$attachUseCases$15(Camera2CameraImpl.java:937)
       at androidx.camera.core.impl.utils.executor.SequentialExecutor$QueueWorker.workOnQueue(SequentialExecutor.java:229)
       at androidx.camera.core.impl.utils.executor.SequentialExecutor$QueueWorker.run(SequentialExecutor.java:171)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-4-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:207)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:228)
       at java.lang.Daemons$FinalizerDaemon.runInternal(Daemons.java:350)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)


Dispositivo
Marca: Xiaomi
Modelo: 25080RABDG
Orientação: Retrato
Espaço livre na memória RAM: 2.14 GiB
Espaço livre no disco: 174.23 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 26 de ago. de 2026, 18:48:27
Versão do app: 1.3.0 (10)
Usuário
Código:93

Fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Null check operator used on a null value
       at State.context(framework.dart:959)
       at _LoginScreenState._showMessage(auth_screen.dart:178)
       at _LoginScreenState._login(auth_screen.dart:173)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

SurfaceSyncGroupTimer:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

InteractionJankMonitor-Worker:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Blocking Thread #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

pool-9-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

flutter-worker-0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Blocking Thread #2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Timer-0:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.util.TimerThread.mainLoop(Timer.java:562)
       at java.util.TimerThread.run(Timer.java:540)

Okio Watchdog:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.okio.AsyncTimeout.awaitTimeout(AsyncTimeout.java:325)
       at com.android.okhttp.okio.AsyncTimeout.access$000(AsyncTimeout.java:42)
       at com.android.okhttp.okio.AsyncTimeout$Watchdog.run(AsyncTimeout.java:288)

pool-9-thread-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerWatchdogDaemon:
       at java.lang.Thread.sleep(Thread.java)
       at java.lang.Thread.sleep0(Thread.java:689)
       at java.lang.Thread.sleep(Thread.java:667)
       at java.lang.Thread.sleep(Thread.java:580)
       at java.lang.Daemons$FinalizerWatchdogDaemon.sleepForNanos(Daemons.java:536)
       at java.lang.Daemons$FinalizerWatchdogDaemon.waitForProgress(Daemons.java:612)
       at java.lang.Daemons$FinalizerWatchdogDaemon.runInternal(Daemons.java:467)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

Timer-1:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.util.TimerThread.mainLoop(Timer.java:562)
       at java.util.TimerThread.run(Timer.java:540)

ActivityHelper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

MiuiMonitorThread:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

FramePredictInitTh:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

FileObserver:
       at android.os.FileObserver$ObserverThread.observe(FileObserver.java)
       at android.os.FileObserver$ObserverThread.run(FileObserver.java:116)

pool-9-thread-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Blocking Thread #0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

FramePolicy:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

main:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.app.ActivityThread.main(ActivityThread.java:10090)
       at java.lang.reflect.Method.invoke(Method.java)
       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:616)
       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1137)

Firebase Blocking Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

queued-work-looper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

AppCustomScenariorHandler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

TouchPolicy:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

Firebase Background Thread #0:
       at dalvik.system.VMStack.getThreadStackTrace(VMStack.java)
       at java.lang.Thread.getStackTrace(Thread.java:2852)
       at java.lang.Thread.getAllStackTraces(Thread.java:2919)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateThreadsList(CrashlyticsReportDataCapture.java:343)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateExecutionData(CrashlyticsReportDataCapture.java:314)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.populateEventApplicationData(CrashlyticsReportDataCapture.java:261)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsReportDataCapture.captureEventData(CrashlyticsReportDataCapture.java:112)
       at com.google.firebase.crashlytics.internal.common.SessionReportingCoordinator.persistEvent(SessionReportingCoordinator.java:371)
       at com.google.firebase.crashlytics.internal.common.SessionReportingCoordinator.persistFatalEvent(SessionReportingCoordinator.java:136)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsController$2.call(CrashlyticsController.java:234)
       at com.google.firebase.crashlytics.internal.common.CrashlyticsController$2.call(CrashlyticsController.java:220)
       at com.google.firebase.crashlytics.internal.concurrency.CrashlyticsWorker.lambda$submitTask$2(CrashlyticsWorker.java:118)
       at com.google.android.gms.tasks.zze.run(zze.java:1)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

9664-ScoutStateMachine:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #2:
       at java.time.LocalDate.getLong(LocalDate.java:683)
       at java.time.LocalDateTime.getLong(LocalDateTime.java:718)
       at java.time.format.DateTimePrintContext.getValue(DateTimePrintContext.java:308)
       at java.time.format.DateTimeFormatterBuilder$NumberPrinterParser.format(DateTimeFormatterBuilder.java:2798)
       at java.time.format.DateTimeFormatterBuilder$CompositePrinterParser.format(DateTimeFormatterBuilder.java:2437)
       at java.time.format.DateTimeFormatter.formatTo(DateTimeFormatter.java:1847)
       at java.time.format.DateTimeFormatter.format(DateTimeFormatter.java:1821)
       at java.time.LocalDateTime.format(LocalDateTime.java:1746)
       at com.google.firebase.heartbeatinfo.HeartBeatInfoStorage.getFormattedDate(HeartBeatInfoStorage.java:186)
       at com.google.firebase.heartbeatinfo.HeartBeatInfoStorage.storeHeartBeat(HeartBeatInfoStorage.java:193)
       at com.google.firebase.heartbeatinfo.DefaultHeartBeatController.lambda$registerHeartBeat$0(DefaultHeartBeatController.java:69)
       at com.google.android.gms.tasks.zzx.run(zzx.java:1)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

Firebase Background Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

flutter-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-5-thread-1:
       at java.net.SocketInputStream.socketRead0(SocketInputStream.java)
       at java.net.SocketInputStream.socketRead(SocketInputStream.java:118)
       at java.net.SocketInputStream.read(SocketInputStream.java:173)
       at java.net.SocketInputStream.read(SocketInputStream.java:143)
       at com.android.org.conscrypt.ConscryptEngineSocket$SSLInputStream.readFromSocket(ConscryptEngineSocket.java:1015)
       at com.android.org.conscrypt.ConscryptEngineSocket$SSLInputStream.processDataFromSocket(ConscryptEngineSocket.java:979)
       at com.android.org.conscrypt.ConscryptEngineSocket$SSLInputStream.readUntilDataAvailable(ConscryptEngineSocket.java:894)
       at com.android.org.conscrypt.ConscryptEngineSocket$SSLInputStream.read(ConscryptEngineSocket.java:867)
       at com.android.okhttp.okio.Okio$2.read(Okio.java:138)
       at com.android.okhttp.okio.AsyncTimeout$2.read(AsyncTimeout.java:213)
       at com.android.okhttp.okio.RealBufferedSource.indexOf(RealBufferedSource.java:307)
       at com.android.okhttp.okio.RealBufferedSource.indexOf(RealBufferedSource.java:301)
       at com.android.okhttp.okio.RealBufferedSource.readUtf8LineStrict(RealBufferedSource.java:197)
       at com.android.okhttp.internal.http.Http1xStream.readResponse(Http1xStream.java:188)
       at com.android.okhttp.internal.http.Http1xStream.readResponseHeaders(Http1xStream.java:129)
       at com.android.okhttp.internal.http.HttpEngine.readNetworkResponse(HttpEngine.java:750)
       at com.android.okhttp.internal.http.HttpEngine.readResponse(HttpEngine.java:622)
       at com.android.okhttp.internal.huc.HttpURLConnectionImpl.execute(HttpURLConnectionImpl.java:475)
       at com.android.okhttp.internal.huc.HttpURLConnectionImpl.getResponse(HttpURLConnectionImpl.java:411)
       at com.android.okhttp.internal.huc.HttpURLConnectionImpl.getResponseCode(HttpURLConnectionImpl.java:542)
       at com.android.okhttp.internal.huc.DelegatingHttpsURLConnection.getResponseCode(DelegatingHttpsURLConnection.java:106)
       at com.android.okhttp.internal.huc.HttpsURLConnectionImpl.getResponseCode(HttpsURLConnectionImpl.java:30)
       at com.google.android.datatransport.cct.CctTransportBackend.doSend(CctTransportBackend.java:355)
       at com.google.android.datatransport.runtime.retries.Retries.retry(Retries.java:54)
       at com.google.android.datatransport.cct.CctTransportBackend.send(CctTransportBackend.java:410)
       at com.google.android.datatransport.runtime.scheduling.jobscheduling.Uploader.logAndUpdateState(Uploader.java:148)
       at com.google.android.datatransport.runtime.scheduling.jobscheduling.Uploader.lambda$upload$1(Uploader.java:106)
       at com.google.android.datatransport.runtime.SafeLoggingExecutor$SafeLoggingRunnable.run(SafeLoggingExecutor.java:47)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ReferenceQueueDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$ReferenceQueueDaemon.runInternal(Daemons.java:262)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

pool-9-thread-4:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-11-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:1170)
       at java.util.concurrent.ScheduledThreadPoolExecutor$DelayedWorkQueue.take(ScheduledThreadPoolExecutor.java:899)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

ScrollPolicy:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

FinalizerDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:207)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:228)
       at java.lang.Daemons$FinalizerDaemon.runInternal(Daemons.java:350)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

AICollector:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:957)
       at android.os.MessageQueue.next(MessageQueue.java:1099)
       at android.os.Looper.loopOnce(Looper.java:217)
       at android.os.Looper.loop(Looper.java:369)
       at android.os.HandlerThread.run(HandlerThread.java:85)

pool-6-thread-1:
       at java.lang.Thread.sleep(Thread.java)
       at java.lang.Thread.sleep0(Thread.java:689)
       at java.lang.Thread.sleep(Thread.java:667)
       at java.lang.Thread.sleep(Thread.java:580)
       at com.google.firebase.crashlytics.internal.send.ReportQueue.sleep(ReportQueue.java:237)
       at com.google.firebase.crashlytics.internal.send.ReportQueue.access$400(ReportQueue.java:38)
       at com.google.firebase.crashlytics.internal.send.ReportQueue$ReportRunnable.run(ReportQueue.java:231)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Dispositivo
Marca: Samsung
Modelo: SM-A556E
Orientação: Retrato
Espaço livre na memória RAM: 2.68 GiB
Espaço livre no disco: 55.73 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 28 de ago. de 2026, 22:04:08
Versão do app: 1.3.0 (10)
Usuário
Código:123

Fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Null check operator used on a null value. Error thrown .
       at _SelfieCaptureScreenState._buildSelfiePage.<fn>.<fn>(selfie_capture_screen.dart:879)
       at _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback(layout_builder.dart:232)
       at BuildOwner.buildScope(framework.dart:3101)
       at _LayoutBuilderElement._rebuildWithConstraints(layout_builder.dart:270)
       at RenderAbstractLayoutBuilderMixin.layoutCallback(layout_builder.dart:333)
       at RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<fn>(object.dart:4162)
       at RenderObject.invokeLayoutCallback.<fn>(object.dart:2887)
       at PipelineOwner._enableMutationsToDirtySubtrees(object.dart:1223)
       at RenderObject.invokeLayoutCallback(object.dart:2886)
       at RenderObjectWithLayoutCallbackMixin.runLayoutCallback(object.dart:4162)
       at _RenderLayoutBuilder.performLayout(layout_builder.dart:447)
       at RenderObject.layout(object.dart:2768)
       at RenderPadding.performLayout(shifted_box.dart:262)
       at RenderObject.layout(object.dart:2768)
       at MultiChildLayoutDelegate.layoutChild(custom_layout.dart:180)
       at _ScaffoldLayout.performLayout(scaffold.dart:1111)
       at MultiChildLayoutDelegate._callPerformLayout(custom_layout.dart:246)
       at RenderCustomMultiChildLayoutBox.performLayout(custom_layout.dart:417)
       at RenderObject._layoutWithoutResize(object.dart:2616)
       at PipelineOwner.flushLayout(object.dart:1174)
       at PipelineOwner.flushLayout(object.dart:1187)
       at RendererBinding.drawFrame(binding.dart:629)
       at WidgetsBinding.drawFrame(binding.dart:1304)
       at RendererBinding._handlePersistentFrameCallback(binding.dart:495)
       at SchedulerBinding._invokeFrameCallback(binding.dart:1430)
       at SchedulerBinding.handleDrawFrame(binding.dart:1345)
       at SchedulerBinding._handleDrawFrame(binding.dart:1198)

CameraX-core_camera_3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

queued-work-looper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

Firebase Background Thread #2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-scheduler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

SurfaceSyncGroupTimer:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

pool-9-thread-6:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Okio Watchdog:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at com.android.okhttp.okio.AsyncTimeout.awaitTimeout(AsyncTimeout.java:313)
       at com.android.okhttp.okio.AsyncTimeout.access$000(AsyncTimeout.java:42)
       at com.android.okhttp.okio.AsyncTimeout$Watchdog.run(AsyncTimeout.java:288)

DefaultDispatcher-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

DefaultDispatcher-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

Firebase Blocking Thread #6:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

ReferenceQueueDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$ReferenceQueueDaemon.runInternal(Daemons.java:262)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

main:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.app.ActivityThread.main(ActivityThread.java:10346)
       at java.lang.reflect.Method.invoke(Method.java)
       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:638)
       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:972)

AsyncTask #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:458)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.take(SynchronousQueue.java:318)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-8-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

android.bg:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

flutter-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerWatchdogDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$FinalizerWatchdogDaemon.sleepUntilNeeded(Daemons.java:483)
       at java.lang.Daemons$FinalizerWatchdogDaemon.runInternal(Daemons.java:463)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

pool-6-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

InteractionJankMonitor-Worker:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

CameraManagerGlobal:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:985)
       at android.os.MessageQueue.next(MessageQueue.java:1094)
       at android.os.Looper.loopOnce(Looper.java:222)
       at android.os.Looper.loop(Looper.java:392)
       at android.os.HandlerThread.run(HandlerThread.java:139)

Firebase Background Thread #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

FileObserver:
       at android.os.FileObserver$ObserverThread.observe(FileObserver.java)
       at android.os.FileObserver$ObserverThread.run(FileObserver.java:116)

FinalizerDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:207)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:228)
       at java.lang.Daemons$FinalizerDaemon.runInternal(Daemons.java:350)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Dispositivo
Marca: Samsung
Modelo: SM-M536B
Orientação: Retrato
Espaço livre na memória RAM: 2.76 GiB
Espaço livre no disco: 25.59 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 25 de ago. de 2026, 17:44:27
Versão do app: 1.3.0 (10)
Usuário
Código:139

Fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Null check operator used on a null value. Error thrown .
       at _SelfieCaptureScreenState._buildSelfiePage.<fn>.<fn>(selfie_capture_screen.dart:879)
       at _LayoutBuilderElement._rebuildWithConstraints.updateChildCallback(layout_builder.dart:232)
       at BuildOwner.buildScope(framework.dart:3101)
       at _LayoutBuilderElement._rebuildWithConstraints(layout_builder.dart:270)
       at RenderAbstractLayoutBuilderMixin.layoutCallback(layout_builder.dart:333)
       at RenderObjectWithLayoutCallbackMixin.runLayoutCallback.<fn>(object.dart:4162)
       at RenderObject.invokeLayoutCallback.<fn>(object.dart:2887)
       at PipelineOwner._enableMutationsToDirtySubtrees(object.dart:1223)
       at RenderObject.invokeLayoutCallback(object.dart:2886)
       at RenderObjectWithLayoutCallbackMixin.runLayoutCallback(object.dart:4162)
       at _RenderLayoutBuilder.performLayout(layout_builder.dart:447)
       at RenderObject.layout(object.dart:2768)
       at RenderPadding.performLayout(shifted_box.dart:262)
       at RenderObject.layout(object.dart:2768)
       at MultiChildLayoutDelegate.layoutChild(custom_layout.dart:180)
       at _ScaffoldLayout.performLayout(scaffold.dart:1111)
       at MultiChildLayoutDelegate._callPerformLayout(custom_layout.dart:246)
       at RenderCustomMultiChildLayoutBox.performLayout(custom_layout.dart:417)
       at RenderObject._layoutWithoutResize(object.dart:2616)
       at PipelineOwner.flushLayout(object.dart:1174)
       at PipelineOwner.flushLayout(object.dart:1187)
       at RendererBinding.drawFrame(binding.dart:629)
       at WidgetsBinding.drawFrame(binding.dart:1304)
       at RendererBinding._handlePersistentFrameCallback(binding.dart:495)
       at SchedulerBinding._invokeFrameCallback(binding.dart:1430)
       at SchedulerBinding.handleDrawFrame(binding.dart:1345)
       at SchedulerBinding._handleDrawFrame(binding.dart:1198)

OkHttp ConnectionPool:
       at java.lang.Object.wait(Object.java)
       at com.android.okhttp.ConnectionPool$1.run(ConnectionPool.java:106)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FinalizerWatchdogDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$FinalizerWatchdogDaemon.sleepUntilNeeded(Daemons.java:483)
       at java.lang.Daemons$FinalizerWatchdogDaemon.runInternal(Daemons.java:463)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

main:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.app.ActivityThread.main(ActivityThread.java:10060)
       at java.lang.reflect.Method.invoke(Method.java)
       at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:632)
       at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:975)

CameraX-core_camera_0:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraManagerGlobal:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.os.HandlerThread.run(HandlerThread.java:85)

DefaultDispatcher-worker-3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

SurfaceSyncGroupTimer:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.os.HandlerThread.run(HandlerThread.java:85)

FinalizerDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:207)
       at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:228)
       at java.lang.Daemons$FinalizerDaemon.runInternal(Daemons.java:350)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-scheduler:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.os.HandlerThread.run(HandlerThread.java:85)

Firebase Background Thread #3:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

ReferenceQueueDaemon:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at java.lang.Daemons$ReferenceQueueDaemon.runInternal(Daemons.java:262)
       at java.lang.Daemons$Daemon.run(Daemons.java:135)
       at java.lang.Thread.run(Thread.java:1572)

InteractionJankMonitor-Worker:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.os.HandlerThread.run(HandlerThread.java:85)

Firebase Background Thread #1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

CameraX-core_camera_1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

pool-9-thread-6:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

DefaultDispatcher-worker-2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.park(CoroutineScheduler.kt:858)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.tryPark(CoroutineScheduler.kt:806)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.runWorker(CoroutineScheduler.kt:754)
       at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:707)

ConscryptStatsLogWriter:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

Okio Watchdog:
       at java.lang.Object.wait(Object.java)
       at java.lang.Object.wait(Object.java:405)
       at java.lang.Object.wait(Object.java:543)
       at com.android.okhttp.okio.AsyncTimeout.awaitTimeout(AsyncTimeout.java:313)
       at com.android.okhttp.okio.AsyncTimeout.access$000(AsyncTimeout.java:42)
       at com.android.okhttp.okio.AsyncTimeout$Watchdog.run(AsyncTimeout.java:288)

queued-work-looper:
       at android.os.MessageQueue.nativePollOnce(MessageQueue.java)
       at android.os.MessageQueue.nextLegacy(MessageQueue.java:950)
       at android.os.MessageQueue.next(MessageQueue.java:1062)
       at android.os.Looper.loopOnce(Looper.java:221)
       at android.os.Looper.loop(Looper.java:363)
       at android.os.HandlerThread.run(HandlerThread.java:85)

Firebase Blocking Thread #6:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:417)
       at java.util.concurrent.LinkedTransferQueue$DualNode.await(LinkedTransferQueue.java:452)
       at java.util.concurrent.SynchronousQueue$Transferer.xferLifo(SynchronousQueue.java:194)
       at java.util.concurrent.SynchronousQueue.xfer(SynchronousQueue.java:235)
       at java.util.concurrent.SynchronousQueue.poll(SynchronousQueue.java:338)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1025)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

Firebase Background Thread #2:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at com.google.firebase.concurrent.CustomThreadFactory.lambda$newThread$0(CustomThreadFactory.java:47)
       at java.lang.Thread.run(Thread.java:1572)

pool-6-thread-1:
       at jdk.internal.misc.Unsafe.park(Unsafe.java)
       at java.util.concurrent.locks.LockSupport.park(LockSupport.java:376)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionNode.block(AbstractQueuedSynchronizer.java:520)
       at java.util.concurrent.ForkJoinPool.unmanagedBlock(ForkJoinPool.java:3797)
       at java.util.concurrent.ForkJoinPool.managedBlock(ForkJoinPool.java:3738)
       at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1752)
       at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:435)
       at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:1026)
       at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1086)
       at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
       at java.lang.Thread.run(Thread.java:1572)

FileObserver:
       at android.os.FileObserver$ObserverThread.observe(FileObserver.java)
       at android.os.FileObserver$ObserverThread.run(FileObserver.java:116)


Dispositivo
Marca: Samsung
Modelo: SM-A315G
Orientação: Retrato
Espaço livre na memória RAM: 1.15 GiB
Espaço livre no disco: 42.27 GiB
Sistema operacional
Versão:Android 12
Orientação: Retrato
Com acesso root: Não
Falha
Data: 27 de ago. de 2026, 06:48:15
Versão do app: 1.3.0 (10)
Usuário
Código:73


Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: ClientException: Connection reset by peer, uri=https://app.coringaplus.com/v1/dbase. Error thrown API GET /v1/dbase -> sem resposta.
       at IOClient.send(io_client.dart:156)
       at BaseClient._sendUnstreamed(base_client.dart:93)
       at ._withClient(http.dart:167)
       at HttpService._send(http_service.dart:67)
       at LoginController.loadPerfis(login_controller.dart:17)
       at _LoginScreenState._loadPerfis(auth_screen.dart:81)


Dispositivo
Marca: Xiaomi
Modelo: 25080RABDG
Orientação: Retrato
Espaço livre na memória RAM: 2.19 GiB
Espaço livre no disco: 174.27 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 26 de ago. de 2026, 18:53:40
Versão do app: 1.3.0 (10)

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: ClientException with SocketException: Software caused connection abort (OS Error: Software caused connection abort, errno = 103), address = app.coringaplus.com, port = 55510, uri=https://app.coringaplus.com/v1/registro. Error thrown API PUT /v1/registro -> sem resposta.
       at IOClient.send(io_client.dart:154)
       at BaseClient._sendUnstreamed(base_client.dart:93)
       at ._withClient(http.dart:167)
       at HttpService._send(http_service.dart:67)
       at RegistroService.registrarPonto(registro_service.dart:44)
       at _SelfieCaptureScreenState._captureImage(selfie_capture_screen.dart:619)


Dispositivo
Marca: Samsung
Modelo: SM-A146M
Orientação: Retrato
Espaço livre na memória RAM: 827.58 MiB
Espaço livre no disco: 35.23 GiB
Sistema operacional
Versão:Android 15
Orientação: Retrato
Com acesso root: Não
Falha
Data: 26 de ago. de 2026, 06:54:54
Versão do app: 1.3.0 (10)
Usuário
Código:109

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: ClientException with SocketException: Failed host lookup: 'app.coringaplus.com' (OS Error: No address associated with hostname, errno = 7), uri=https://app.coringaplus.com/v1/login. Error thrown API POST /v1/login -> sem resposta.
       at IOClient.send(io_client.dart:154)
       at BaseClient._sendUnstreamed(base_client.dart:93)
       at ._withClient(http.dart:167)
       at HttpService._send(http_service.dart:67)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Samsung
Modelo: SM-S711B
Orientação: Retrato
Espaço livre na memória RAM: 2.42 GiB
Espaço livre no disco: 2.87 GiB
Sistema operacional
Versão:Android 15
Orientação: Retrato
Com acesso root: Não
Falha
Data: 29 de ago. de 2026, 18:32:07
Versão do app: 1.3.0 (10)
Usuário
Código:178

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Xiaomi
Modelo: 23028RA60L
Orientação: Retrato
Espaço livre na memória RAM: 1.24 GiB
Espaço livre no disco: 16.07 GiB
Sistema operacional
Versão:Android 15
Orientação: Retrato
Com acesso root: Não
Falha
Data: 29 de ago. de 2026, 07:13:40
Versão do app: 1.3.0 (10)
Usuário
Código:97

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Samsung
Modelo: SM-A556E
Orientação: Retrato
Espaço livre na memória RAM: 2.74 GiB
Espaço livre no disco: 55.73 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 28 de ago. de 2026, 22:01:59
Versão do app: 1.3.0 (10)
Usuário
Código:123

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Samsung
Modelo: SM-A175F
Orientação: Retrato
Espaço livre na memória RAM: 1.95 GiB
Espaço livre no disco: 146.75 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 28 de ago. de 2026, 07:08:02
Versão do app: 1.3.0 (10)
Usuário
Código:108

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Xiaomi
Modelo: 2510DRA23L
Orientação: Retrato
Espaço livre na memória RAM: 2.87 GiB
Espaço livre no disco: 192.1 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 28 de ago. de 2026, 07:00:58
Versão do app: 1.3.0 (10)
Usuário
Código:92

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Samsung
Modelo: SM-S711B
Orientação: Retrato
Espaço livre na memória RAM: 1.78 GiB
Espaço livre no disco: 7.84 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 25 de ago. de 2026, 19:08:04
Versão do app: 1.3.0 (10)
Usuário
Código:95

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Samsung
Modelo: SM-M536B
Orientação: Retrato
Espaço livre na memória RAM: 2.64 GiB
Espaço livre no disco: 25.59 GiB
Sistema operacional
Versão:Android 16
Orientação: Retrato
Com acesso root: Não
Falha
Data: 25 de ago. de 2026, 17:42:13
Versão do app: 1.3.0 (10)
Usuário
Código:139

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API POST /v1/login -> 400. Error thrown API POST /v1/login -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at LoginController.login(login_controller.dart:39)
       at _LoginScreenState._login(auth_screen.dart:160)

Dispositivo
Marca: Motorola
Modelo: Moto G05
Orientação: Retrato
Espaço livre na memória RAM: 1.04 GiB
Espaço livre no disco: 52.14 GiB
Sistema operacional
Versão:Android 15
Orientação: Retrato
Com acesso root: Não
Falha
Data: 25 de ago. de 2026, 15:55:47
Versão do app: 1.3.0 (10)
Usuário
Código:707

Non-fatal Exception: io.flutter.plugins.firebase.crashlytics.FlutterError: Exception: API GET /v1/plantoesHistorico/707/61 -> 400. Error thrown API GET /v1/plantoesHistorico/707/61 -> 400.
       at CrashReportingService.recordApiError(crash_reporting_service.dart:71)
       at HttpService._send(http_service.dart:79)
       at PlantaoService.buscarHistoricoPlantoes(plantao_service.dart:21)
       at PlantaoController.listarHistoricoPlantoes(plantao_controller.dart:46)
       at _MeusPlantoesScreenState._carregarHistorico(meus_plantoes_screen.dart:73)

