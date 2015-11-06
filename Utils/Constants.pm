package Utils::Constants;

use strict;
use warnings;

use Exporter qw(import);

use constant STATUS_CODE_SUCCESS => 200;

use constant STATUS_CODE_CONFLICT_CHANNELID_ERROR => 409;

use constant STATUS_CODE_INTERNAL_SERVER_ERROR => 500;

use constant MESSAGE_QUEUE_EVENT_ACK => 'ack';

use constant NOTIFICATION_RESEND_INTERVAL_IN_MINS => 5;

use constant NEW_MESSAGE_LISTENER_TOPIC => 'new_message';

use constant SERVER_ADDRESS => 'http://127.0.0.1:3000/';

use constant APPSERVER_PUSH_DIR => 'push';

1;
