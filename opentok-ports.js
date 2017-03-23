window.opentokPorts = ports => {
  const sessions = {};

  ports.connect.subscribe(credentials => {
    const { apiKey, sessionId, token } = credentials;

    if (sessions[sessionId]) {
      ports.connectCallback.send({
        sessionId,
        success: false,
        message: `Already called connect once on session with ID: ${sessionId}`
      });
      return;
    }

    const session = OT.initSession(apiKey, sessionId);
    const streams = {};
    sessions[sessionId] = { session, streams, subscribers: {} };

    const streamCreated = event => {
      const { stream } = event;
      const { streamId } = stream;
      streams[streamId] = stream;
      ports.onStreamCreated.send({ sessionId, streamId });
    };

    const streamDestroyed = event => {
      const { streamId } = event.stream;
      delete streams[streamId];
      ports.onStreamDestroyed.send({ sessionId, streamId });
    };

    const eventHandlers = { streamCreated, streamDestroyed };
    session.on(eventHandlers);
    sessions[sessionId].eventHandlers = eventHandlers;

    session.connect(token, err => {
      const success = !Boolean(err);
      const message = err ? String(err.message) : '';
      ports.connectCallback.send({ sessionId, success, message });
    });
  });

  ports.disconnect.subscribe(options => {
    const { sessionId } = options;

    if (sessions[sessionId]) {
      const { session, subscribers, publisher, eventHandlers } = sessions[sessionId];
      session.off(eventHandlers);
      Object.keys(subscribers).forEach(streamId => {
        session.unsubscribe(subscribers[streamId]);
      });
      session.unpublish(publisher);
      session.disconnect();
      session.destroy();
      delete sessions[sessionId];
    }
  });

  ports.publish.subscribe(options => {
    const { sessionId, containerId } = options;
    const properties = {}; // FIXME

    if (!sessions[sessionId]) {
      ports.publishCallback.send({
        sessionId,
        success: false,
        message: `Could not publish to unknown session with ID: ${sessionId}`
      });
      return;
    }

    const { session } = sessions[sessionId];

    const container = document.createElement('div');
    const publisher = session.publish(container, properties, err => {
      const success = !Boolean(err);
      const message = err ? String(err.message) : '';
      const streamId = success ? publisher.stream.streamId : '';
      ports.publishCallback.send({ sessionId, streamId, success, message });
    });
    const appendContainer = () => {
      const el = document.getElementById(containerId);
      if (el) {
        el.appendChild(container);
      } else {
        setTimeout(appendContainer, 100);
      }
    };
    publisher.once('videoElementCreated', appendContainer);
    sessions[sessionId].publisher = publisher;
  });

  ports.subscribe.subscribe(options => {
    const { sessionId, streamId, containerId } = options;
    const properties = {}; // FIXME

    if (!sessions[sessionId]) {
      ports.subscribeCallback.send({
        sessionId,
        streamId,
        success: false,
        message: `Could not subscribe to unknown session with ID: ${sessionId}`
      });
      return;
    }

    const { session, streams, subscribers } = sessions[sessionId];

    const stream = streams[streamId];
    if (!stream) {
      ports.subscribeCallback.send({
        sessionId,
        streamId,
        success: false,
        message: `Could not subscribe to unknown stream with ID: ${streamId}`
      });
      return;
    }

    const container = document.createElement('div');
    const subscriber = session.subscribe(stream, container, properties, err => {
      const success = !Boolean(err);
      const message = err ? String(err.message) : '';
      ports.subscribeCallback.send({ sessionId, streamId, success, message });
    });
    const appendContainer = () => {
      const el = document.getElementById(containerId);
      if (el) {
        el.appendChild(container);
      } else {
        setTimeout(appendContainer, 100);
      }
    };
    subscriber.once('videoElementCreated', appendContainer);
    subscribers[streamId] = subscriber;
  });

  ports.unsubscribe.subscribe(options => {
    const { sessionId, streamId } = options;

    if (!sessions[sessionId]) {
      return;
    }

    const { session, subscribers } = sessions[sessionId];

    if (!subscribers[streamId]) {
      return;
    }

    session.unsubscribe(subscribers[streamId]);
  });
};
