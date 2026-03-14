const BiometricReading = require('../../src/models/BiometricReading');
const DailySummary = require('../../src/models/DailySummary');
const controller = require('../../src/controllers/biometricsController');

jest.mock('../../src/models/BiometricReading');
jest.mock('../../src/models/DailySummary');

describe('biometricsController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      user: { sub: 'user-123' },
      body: {},
      query: {},
      params: {},
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('recordReading', () => {
    it('should create a reading and return 201', async () => {
      const mockReading = {
        _id: 'reading-1',
        userSub: 'user-123',
        type: 'heart_rate',
        value: 72,
        unit: 'bpm',
        source: 'smart_ring',
        metadata: {},
        recordedAt: new Date('2026-03-14T10:00:00Z'),
      };

      req.body = {
        type: 'heart_rate',
        value: 72,
        unit: 'bpm',
        source: 'smart_ring',
        recordedAt: '2026-03-14T10:00:00Z',
      };

      BiometricReading.create.mockResolvedValue(mockReading);

      await controller.recordReading(req, res);

      expect(BiometricReading.create).toHaveBeenCalledWith(
        expect.objectContaining({
          userSub: 'user-123',
          type: 'heart_rate',
          value: 72,
          unit: 'bpm',
          source: 'smart_ring',
        })
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ reading: mockReading });
    });

    it('should return 500 when creation fails', async () => {
      req.body = { type: 'heart_rate', value: 72, unit: 'bpm' };
      BiometricReading.create.mockRejectedValue(new Error('DB error'));

      await controller.recordReading(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Failed to record reading' });
    });

    it('should default source to smart_ring when not provided', async () => {
      req.body = { type: 'heart_rate', value: 72, unit: 'bpm' };
      BiometricReading.create.mockResolvedValue({ _id: 'r1' });

      await controller.recordReading(req, res);

      expect(BiometricReading.create).toHaveBeenCalledWith(
        expect.objectContaining({ source: 'smart_ring' })
      );
    });
  });

  describe('recordBatch', () => {
    it('should insert multiple readings and return 201 with count', async () => {
      const readings = [
        { type: 'heart_rate', value: 72, unit: 'bpm' },
        { type: 'spo2', value: 98, unit: '%' },
        { type: 'steps', value: 150, unit: 'count' },
      ];
      req.body = { readings };

      BiometricReading.insertMany.mockResolvedValue(readings);

      await controller.recordBatch(req, res);

      expect(BiometricReading.insertMany).toHaveBeenCalledWith(
        expect.arrayContaining([
          expect.objectContaining({ userSub: 'user-123', type: 'heart_rate', value: 72 }),
          expect.objectContaining({ userSub: 'user-123', type: 'spo2', value: 98 }),
        ])
      );
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({ count: 3 });
    });

    it('should return 400 when readings array is empty', async () => {
      req.body = { readings: [] };

      await controller.recordBatch(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Readings array required' });
    });

    it('should return 400 when readings is not an array', async () => {
      req.body = { readings: 'not-an-array' };

      await controller.recordBatch(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Readings array required' });
    });

    it('should return 500 when insertMany fails', async () => {
      req.body = { readings: [{ type: 'heart_rate', value: 72, unit: 'bpm' }] };
      BiometricReading.insertMany.mockRejectedValue(new Error('DB error'));

      await controller.recordBatch(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Failed to record batch' });
    });
  });

  describe('getHistory', () => {
    it('should return filtered readings', async () => {
      const mockReadings = [
        { _id: 'r1', type: 'heart_rate', value: 72 },
        { _id: 'r2', type: 'heart_rate', value: 75 },
      ];

      req.query = { type: 'heart_rate', limit: '50' };

      const mockQuery = {
        sort: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(mockReadings),
      };
      BiometricReading.find.mockReturnValue(mockQuery);

      await controller.getHistory(req, res);

      expect(BiometricReading.find).toHaveBeenCalledWith(
        expect.objectContaining({
          userSub: 'user-123',
          type: 'heart_rate',
        })
      );
      expect(mockQuery.sort).toHaveBeenCalledWith({ recordedAt: -1 });
      expect(mockQuery.limit).toHaveBeenCalledWith(50);
      expect(res.json).toHaveBeenCalledWith({ readings: mockReadings });
    });

    it('should apply date range filters when from and to are provided', async () => {
      req.query = { from: '2026-03-01', to: '2026-03-14' };

      const mockQuery = {
        sort: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue([]),
      };
      BiometricReading.find.mockReturnValue(mockQuery);

      await controller.getHistory(req, res);

      const filter = BiometricReading.find.mock.calls[0][0];
      expect(filter.userSub).toBe('user-123');
      expect(filter.recordedAt.$gte).toEqual(new Date('2026-03-01'));
      expect(filter.recordedAt.$lte).toEqual(new Date('2026-03-14'));
    });

    it('should default limit to 100 when not provided', async () => {
      req.query = {};

      const mockQuery = {
        sort: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue([]),
      };
      BiometricReading.find.mockReturnValue(mockQuery);

      await controller.getHistory(req, res);

      expect(mockQuery.limit).toHaveBeenCalledWith(100);
    });

    it('should return 500 when find fails', async () => {
      req.query = {};
      BiometricReading.find.mockImplementation(() => {
        throw new Error('DB error');
      });

      await controller.getHistory(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Failed to fetch history' });
    });
  });

  describe('getLatest', () => {
    it('should return latest reading per type', async () => {
      const mockHrReading = { _id: 'r1', type: 'heart_rate', value: 72 };
      const mockSpo2Reading = { _id: 'r2', type: 'spo2', value: 98 };

      const mockQuery = {
        sort: jest.fn().mockReturnThis(),
        lean: jest.fn(),
      };

      BiometricReading.findOne.mockReturnValue(mockQuery);

      // Return readings for heart_rate and spo2, null for others
      mockQuery.lean
        .mockResolvedValueOnce(mockHrReading)   // heart_rate
        .mockResolvedValueOnce(null)              // hrv
        .mockResolvedValueOnce(mockSpo2Reading)   // spo2
        .mockResolvedValueOnce(null)              // temperature
        .mockResolvedValueOnce(null)              // steps
        .mockResolvedValueOnce(null);             // stress

      await controller.getLatest(req, res);

      expect(BiometricReading.findOne).toHaveBeenCalledTimes(6);
      expect(BiometricReading.findOne).toHaveBeenCalledWith(
        expect.objectContaining({ userSub: 'user-123', type: 'heart_rate' })
      );

      const result = res.json.mock.calls[0][0];
      expect(result.latest.heart_rate).toEqual(mockHrReading);
      expect(result.latest.spo2).toEqual(mockSpo2Reading);
      expect(result.latest.hrv).toBeUndefined();
    });

    it('should return empty object when no readings exist', async () => {
      const mockQuery = {
        sort: jest.fn().mockReturnThis(),
        lean: jest.fn().mockResolvedValue(null),
      };
      BiometricReading.findOne.mockReturnValue(mockQuery);

      await controller.getLatest(req, res);

      expect(res.json).toHaveBeenCalledWith({ latest: {} });
    });

    it('should return 500 when query fails', async () => {
      BiometricReading.findOne.mockImplementation(() => {
        throw new Error('DB error');
      });

      await controller.getLatest(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Failed to fetch latest readings' });
    });
  });
});
