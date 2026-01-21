/**
 * Multimodal client for handling webcam/screen video and audio streaming to Gemini Live API
 * Tata Neu Customer Care Assistant
 */

class MultimodalClient extends AudioClient {
    constructor(serverUrl = TATA_NEU_SERVER_URL) {
        super(serverUrl);

        // Video streaming properties
        this.videoStream = null;
        this.videoElement = null;
        this.isVideoActive = false;
        this.videoSendInterval = null;
        this.videoFrameRate = 1; // Send 1 frame per second by default
        this.videoMode = null; // 'webcam' or 'screen'
        this.screenTrack = null;

        // Override reconnection settings from parent class
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 0; // Prevent automatic reconnection
        this.isReconnecting = false;
    }

    // Initialize webcam
    async initializeWebcam(videoElement) {
        if (!videoElement) {
            console.error('Video element is required');
            return false;
        }

        // First, clean up any existing streams
        this.stopVideo();

        this.videoElement = videoElement;
        this.videoMode = 'webcam';

        try {
            // Request camera access
            this.videoStream = await navigator.mediaDevices.getUserMedia({
                video: {
                    width: { ideal: 640 },
                    height: { ideal: 480 }
                }
            });

            // Set video element source
            this.videoElement.srcObject = this.videoStream;
            this.isVideoActive = true;

            return true;
        } catch (error) {
            console.error('Error initializing webcam:', error);
            return false;
        }
    }

    // Initialize screen sharing
    async initializeScreenShare(videoElement) {
        if (!videoElement) {
            console.error('Video element is required');
            return false;
        }

        // First, clean up any existing streams
        this.stopVideo();

        this.videoElement = videoElement;
        this.videoMode = 'screen';

        try {
            // Request screen sharing access
            this.videoStream = await navigator.mediaDevices.getDisplayMedia({
                video: {
                    cursor: "always"
                },
                audio: false
            });

            // Keep reference to screen track for cleanup
            this.screenTrack = this.videoStream.getVideoTracks()[0];

            // Listen for when user stops sharing via browser UI
            this.screenTrack.onended = () => {
                console.log('User ended screen sharing');
                this.stopVideo();
                // Trigger custom event for UI updates
                window.dispatchEvent(new CustomEvent('screenshare-ended'));
            };

            // Set video element source
            this.videoElement.srcObject = this.videoStream;
            this.isVideoActive = true;

            return true;
        } catch (error) {
            console.error('Error initializing screen sharing:', error);
            return false;
        }
    }

    // Start sending video frames to server
    startVideoStream(frameRate = 1) {
        if (!this.isVideoActive || !this.isConnected) {
            console.error('Video is not active or not connected to server');
            return false;
        }

        this.videoFrameRate = frameRate;

        // Clear existing interval if any
        if (this.videoSendInterval) {
            clearInterval(this.videoSendInterval);
        }

        // Create a canvas element for frame capture
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');

        // Set canvas size to match video
        canvas.width = this.videoElement.videoWidth || 640;
        canvas.height = this.videoElement.videoHeight || 480;

        // Start sending frames at specified rate
        this.videoSendInterval = setInterval(() => {
            if (!this.isConnected || !this.isVideoActive) {
                clearInterval(this.videoSendInterval);
                this.videoSendInterval = null;
                return;
            }

            try {
                // Draw current video frame to canvas (scale down for performance)
                canvas.width = this.videoElement.videoWidth * 0.5;
                canvas.height = this.videoElement.videoHeight * 0.5;
                context.drawImage(this.videoElement, 0, 0, canvas.width, canvas.height);

                // Convert canvas to JPEG base64
                const base64Data = canvas.toDataURL('image/jpeg', 0.6).split(',')[1];

                // Send to server following cymbal-auto protocol
                this.ws.send(JSON.stringify({
                    type: 'video',
                    data: base64Data,
                    mimeType: 'image/jpeg'
                }));
            } catch (error) {
                console.error('Error capturing video frame:', error);
            }
        }, 1000 / this.videoFrameRate);

        return true;
    }

    // Stop sending video frames
    stopVideoStream() {
        if (this.videoSendInterval) {
            clearInterval(this.videoSendInterval);
            this.videoSendInterval = null;
        }
    }

    // Stop all video and notify server
    stopVideo() {
        this.stopVideoStream();

        // Notify server that camera is off (following cymbal-auto pattern)
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({
                type: 'text',
                data: '((SYSTEM: User has turned OFF the camera))'
            }));
        }

        if (this.videoStream) {
            this.videoStream.getTracks().forEach(track => track.stop());
            this.videoStream = null;
        }

        if (this.videoElement) {
            this.videoElement.srcObject = null;
        }

        this.screenTrack = null;
        this.isVideoActive = false;
        this.videoMode = null;
    }

    // Get current video mode
    getVideoMode() {
        return this.videoMode;
    }

    // Check if video is active
    isVideoStreamActive() {
        return this.isVideoActive;
    }

    // Override connect method to handle connection more carefully
    async connect() {
        // If already connected or connecting, don't try to connect again
        if (this.ws && (this.ws.readyState === WebSocket.CONNECTING || this.ws.readyState === WebSocket.OPEN)) {
            console.log('Already connected or connecting. Not creating new connection.');
            if (this.isConnected) return Promise.resolve();

            // Wait for connection to complete
            return new Promise((resolve, reject) => {
                const checkConnection = () => {
                    if (this.isConnected) {
                        resolve();
                    } else if (this.ws.readyState === WebSocket.CLOSED || this.ws.readyState === WebSocket.CLOSING) {
                        reject(new Error('WebSocket closed during connection attempt'));
                    } else {
                        setTimeout(checkConnection, 100);
                    }
                };
                checkConnection();
            });
        }

        // Actually connect if we're not already trying to
        return super.connect();
    }

    // Override tryReconnect to be more controlled about reconnection
    async tryReconnect() {
        if (this.isReconnecting || this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.log('Not reconnecting due to settings or already trying');
            return;
        }

        this.isReconnecting = true;
        this.reconnectAttempts++;

        try {
            await this.connect();
            console.log('Reconnected successfully');
        } catch (error) {
            console.error('Reconnection failed:', error);
        } finally {
            this.isReconnecting = false;
        }
    }

    // Override the close method to also clean up video resources
    close() {
        this.stopVideoStream();
        this.stopVideo();
        super.close();
    }
}
