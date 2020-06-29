trigger AttachmentTrigger on Attachment (After insert) {

    Attorney_AttachmentHandler.pushAttachmentsToNDS();
    
}
// Akash