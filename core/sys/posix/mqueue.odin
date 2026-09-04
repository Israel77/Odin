#+build linux, freebsd, netbsd
package posix

import "core:c"

foreign import "system:rt"

foreign rt {
	/*
	Establishes a connection between a process and a message queue.

	The `name` argument must begin with a slash and must not contain any
	additional slashes. When `flags` contains `O_CREAT`, the variadic 
    arguments are `mode_t` followed by `^mq_attr`.

	Returns: `-1` (setting errno) on failure, the queue descriptor
	otherwise.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_open.html ]]
	*/
	mq_open :: proc(name: cstring, flags: c.int, #c_vararg mode: ..any) -> mqd_t ---

	/*
	Closes the message queue descriptor.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_close.html ]]
	*/
	mq_close :: proc(mqdes: mqd_t) -> c.int ---

	/*
	Removes a message queue name from the namespace.

	The queue remains available to existing descriptors until all of them
	have been closed.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_unlink.html ]]
	*/
	mq_unlink :: proc(name: cstring) -> c.int ---

	/*
	Registers or removes asynchronous notification for a message queue.

	The `sevp` argument is a pointer to a C `struct sigevent`, or nil to
	remove an existing registration. It is `rawptr` because the layout of
	`struct sigevent` is platform-specific.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_notify.html ]]
	*/
	mq_notify :: proc(mqdes: mqd_t, sevp: rawptr) -> c.int ---

	/*
	Adds a message to the queue.

	Messages are ordered first by descending priority and then by insertion
	order among messages with equal priority.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_send.html ]]
	*/
	mq_send :: proc(mqdes: mqd_t, msg: [^]c.char, msg_len: c.size_t, msg_prio: c.uint) -> c.int ---

	/*
	Receives the highest-priority message currently available.

	The caller must provide a buffer large enough for the queue's
	`mq_msgsize`. On success, `msg_prio` receives the message priority.

	Returns: -1 (setting errno) on failure, the message length otherwise.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_receive.html ]]
	*/
	mq_receive :: proc(mqdes: mqd_t, msg: [^]c.char, msg_len: c.size_t, msg_prio: ^c.uint) -> c.ssize_t ---

	/*
	Adds a message to the queue, waiting until the absolute timeout if
	the queue is full.

	The timeout is an absolute `CLOCK_REALTIME` deadline.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_timedsend.html ]]
	*/
	@(link_name = LMQ_TIMEDSEND)
	mq_timedsend :: proc(mqdes: mqd_t, msg: [^]c.char, msg_len: c.size_t, msg_prio: c.uint, timeout: ^timespec) -> c.int ---

	/*
	Receives a message, waiting until the absolute timeout if the queue is
	empty.

	The timeout is an absolute `CLOCK_REALTIME` deadline. On success,
	`msg_prio` receives the message priority.

	Returns: -1 (setting errno) on failure, the message length otherwise.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_timedreceive.html ]]
	*/
	@(link_name = LMQ_TIMEDRECEIVE)
	mq_timedreceive :: proc(mqdes: mqd_t, msg: [^]c.char, msg_len: c.size_t, msg_prio: ^c.uint, timeout: ^timespec) -> c.ssize_t ---

	/*
	Returns the attributes associated with a message queue.

	`attr` receives the queue attributes, including its current message
	count and the non-blocking flag.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_getattr.html ]]
	*/
	mq_getattr :: proc(mqdes: mqd_t, attr: ^mq_attr) -> c.int ---

	/*
	Updates the message queue attributes.

	Only the `mq_flags` field is modified; the remaining fields are ignored
	on input. When `old_attr` is non-nil, it receives the previous
	attributes.

	Returns: -1 (setting errno) on failure, 0 on success.

	[[ More; https://pubs.opengroup.org/onlinepubs/9699919799/functions/mq_setattr.html ]]
	*/
	mq_setattr :: proc(mqdes: mqd_t, attr: ^mq_attr, old_attr: ^mq_attr) -> c.int ---
}

mqd_t :: distinct c.int

when ODIN_OS == .NetBSD {
	@(private)
	LMQ_TIMEDSEND :: "__mq_timedsend50"
	@(private)
	LMQ_TIMEDRECEIVE :: "__mq_timedreceive50"
} else {
	@(private)
	LMQ_TIMEDSEND :: "mq_timedsend"
	@(private)
	LMQ_TIMEDRECEIVE :: "mq_timedreceive"
}

when ODIN_OS == .NetBSD {

	mq_attr :: struct {
		mq_flags:   c.long, /* [PSX] flags set for the message queue */
		mq_maxmsg:  c.long, /* [PSX] maximum number of messages in the queue */
		mq_msgsize: c.long, /* [PSX] maximum size of each message */
		mq_curmsgs: c.long, /* [PSX] number of messages currently queued */
	}

} else when ODIN_OS == .Linux || ODIN_OS == .FreeBSD {

	mq_attr :: struct {
		mq_flags:   c.long, /* [PSX] flags set for the message queue */
		mq_maxmsg:  c.long, /* [PSX] maximum number of messages in the queue */
		mq_msgsize: c.long, /* [PSX] maximum size of each message */
		mq_curmsgs: c.long, /* [PSX] number of messages currently queued */
		__reserved: [4]c.long,
	}
}
