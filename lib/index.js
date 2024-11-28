const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Cloud Function to notify admins when a submission is created
exports.notifyAdminOnSubmission = functions.firestore
    .document("submissions/{submissionId}")
    .onCreate((snapshot, context) => {
        const data = snapshot.data();
        const location = data.lokasi; // Ensure location field exists in submission data

        let topic;
        // Determine which admin topic to send based on location
        switch (location) {
            case "KUALA PILAH":
            case "JEMPOL":
            case "JOHOL":
                topic = "admin_shahera";
                break;
            case "NILAI":
            case "PORT DICKSON":
            case "JELEBU":
                topic = "admin_hidayah";
                break;
            case "REMBAU":
            case "TAMPIN":
            case "GEMAS":
                topic = "admin_suriaty";
                break;
            case "MENARA MAINS":
            case "SENAWANG":
            case "SEREMBAN 2":
                topic = "admin_erma_fikri";
                break;
            default:
                console.log("No topic matched for location:", location);
                return null;
        }

        // Define the notification message
        const message = {
            notification: {
                title: "New Submission Alert",
                body: `New submission from ${location}`,
            },
            topic: topic,
        };

        // Send the message using Firebase Cloud Messaging
        return admin.messaging().send(message)
            .then((response) => {
                console.log("Successfully sent message:", response);
                return null;
            })
            .catch((error) => {
                console.error("Error sending message:", error);
            });
    });
