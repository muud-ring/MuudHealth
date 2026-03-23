const { validationResult } = require('express-validator');
const validate = require('../../src/middleware/validate');

// Mock express-validator
jest.mock('express-validator', () => ({
  validationResult: jest.fn(),
}));

describe('validate middleware', () => {
  let req, res, next;

  beforeEach(() => {
    req = {};
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
  });

  it('should call next() when there are no validation errors', () => {
    validationResult.mockReturnValue({
      isEmpty: () => true,
      array: () => [],
    });

    validate(req, res, next);

    expect(next).toHaveBeenCalledTimes(1);
    expect(res.status).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });

  it('should return 400 with error array when validation fails', () => {
    const mockErrors = [
      { msg: 'Type is required', path: 'type', location: 'body' },
      { msg: 'Value must be a number', path: 'value', location: 'body' },
    ];

    validationResult.mockReturnValue({
      isEmpty: () => false,
      array: () => mockErrors,
    });

    validate(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ errors: mockErrors });
  });
});
