const logger = require('../utils/logger');

function errorHandler(err, req, res, next) {
  // Log the error
  logger.error({
    err,
    method: req.method,
    url: req.originalUrl,
    body: req.body,
    user: req.user?.sub,
  }, 'Unhandled error');

  // Don't leak error details in production
  const isProd = process.env.NODE_ENV === 'production';

  const statusCode = err.status || err.statusCode || 500;
  const message = isProd && statusCode === 500
    ? 'Internal server error'
    : err.message || 'Internal server error';

  res.status(statusCode).json({
    error: message,
    ...(isProd ? {} : { stack: err.stack }),
  });
}

module.exports = errorHandler;
