// Prototype server — fully self-contained with mock data layer
// No MongoDB required — everything runs in-memory
// Usage: node src/prototype.js

const path = require('path');
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

// Set env before any imports that read it
process.env.DEV_AUTH = 'true';
process.env.COGNITO_USER_POOL_ID = 'dev-pool';
process.env.AWS_REGION = 'us-west-2';
process.env.PORT = process.env.PORT || '4000';
process.env.ALLOWED_ORIGINS = 'http://localhost:4000';

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

// Serve prototype web UI
app.use(express.static(path.join(__dirname, '..', 'prototype')));

// ─── In-Memory Data Store ────────────────────────────────────
const db = {
  users: [],
  connections: [],
  friendRequests: [],
  conversations: [],
  messages: [],
  posts: [],
  biometricReadings: [],
  dailySummaries: [],
  onboarding: [],
};

let idCounter = 1;
function newId() { return (idCounter++).toString().padStart(24, '0'); }

// ─── Seed Data ──────────────────────────────────────────────
function seedData() {
  const users = [
    { _id: newId(), sub: 'dev-alex', name: 'Alex Johnson', username: 'alex', bio: 'Wellness enthusiast. Love hiking and meditation.', location: 'San Francisco, CA', avatarKey: '' },
    { _id: newId(), sub: 'dev-sam', name: 'Sam Rivera', username: 'sam', bio: 'Yoga instructor & mindfulness coach.', location: 'Austin, TX', avatarKey: '' },
    { _id: newId(), sub: 'dev-jordan', name: 'Jordan Lee', username: 'jordan', bio: 'Runner, reader, always growing.', location: 'Portland, OR', avatarKey: '' },
    { _id: newId(), sub: 'dev-taylor', name: 'Taylor Chen', username: 'taylor', bio: 'Nutrition geek. Plant-based life.', location: 'Seattle, WA', avatarKey: '' },
    { _id: newId(), sub: 'dev-morgan', name: 'Morgan Davis', username: 'morgan', bio: 'Sleep scientist by day, night owl by... well.', location: 'Denver, CO', avatarKey: '' },
    { _id: newId(), sub: 'dev-casey', name: 'Casey Park', username: 'casey', bio: 'Mental health advocate. Let\'s talk.', location: 'New York, NY', avatarKey: '' },
  ];
  db.users = users;

  // Connections (sorted IDs)
  const pairs = [[0,1,'inner_circle'],[0,2,'connection'],[0,3,'connection'],[1,2,'connection']];
  pairs.forEach(([a, b, tier]) => {
    const idA = users[a]._id < users[b]._id ? users[a]._id : users[b]._id;
    const idB = idA === users[a]._id ? users[b]._id : users[a]._id;
    db.connections.push({ _id: newId(), userA: idA, userB: idB, tier });
  });

  // Friend request
  db.friendRequests.push({ _id: newId(), fromSub: 'dev-morgan', toSub: 'dev-alex', status: 'pending', createdAt: new Date() });

  // Conversations + messages
  const c1Id = newId();
  db.conversations.push({
    _id: c1Id, members: ['dev-alex', 'dev-sam'],
    membersKey: ['dev-alex', 'dev-sam'].sort().join('|'),
    lastMessage: 'See you at yoga tomorrow!',
    lastMessageAt: new Date(Date.now() - 3600000),
  });

  const msgs = [
    { from: 'dev-sam', to: 'dev-alex', text: 'Hey! How was your meditation today?', read: true, ago: 6 },
    { from: 'dev-alex', to: 'dev-sam', text: 'It was great! 20 minutes this morning.', read: true, ago: 5 },
    { from: 'dev-sam', to: 'dev-alex', text: 'Want to join my yoga class tomorrow?', read: true, ago: 4 },
    { from: 'dev-alex', to: 'dev-sam', text: 'Absolutely! What time?', read: true, ago: 3 },
    { from: 'dev-sam', to: 'dev-alex', text: '8 AM at the studio.', read: true, ago: 2 },
    { from: 'dev-alex', to: 'dev-sam', text: 'See you at yoga tomorrow!', read: false, ago: 1 },
  ];
  msgs.forEach(m => {
    db.messages.push({
      _id: newId(), conversationId: c1Id, fromSub: m.from, toSub: m.to,
      text: m.text, readAt: m.read ? new Date() : null,
      createdAt: new Date(Date.now() - m.ago * 600000),
    });
  });

  const c2Id = newId();
  db.conversations.push({
    _id: c2Id, members: ['dev-alex', 'dev-jordan'],
    membersKey: ['dev-alex', 'dev-jordan'].sort().join('|'),
    lastMessage: 'Just hit a new PR on my 5K!',
    lastMessageAt: new Date(Date.now() - 7200000),
  });
  db.messages.push({
    _id: newId(), conversationId: c2Id, fromSub: 'dev-jordan', toSub: 'dev-alex',
    text: 'Just hit a new PR on my 5K! 22:30!', readAt: null,
    createdAt: new Date(Date.now() - 7200000),
  });

  // Posts
  const posts = [
    { authorSub: 'dev-alex', caption: 'Morning meditation by the bay. 20 minutes of breathwork and I feel ready for anything.', visibility: 'connections', ago: 5 },
    { authorSub: 'dev-sam', caption: 'Today\'s yoga class was incredible \u2014 heart-opening poses. Growth happens outside your comfort zone.', visibility: 'public', ago: 4 },
    { authorSub: 'dev-jordan', caption: 'New PR: 5K in 22:30! Consistent training pays off. Start with just 10 minutes a day.', visibility: 'public', ago: 3 },
    { authorSub: 'dev-taylor', caption: 'Beautiful buddha bowl \u2014 quinoa, roasted sweet potato, avocado, tahini dressing. Nourish your body!', visibility: 'public', ago: 2 },
    { authorSub: 'dev-alex', caption: 'Week 3 of sleep tracking with the ring. Deep sleep improved 15%. Data-driven wellness is the future.', visibility: 'connections', ago: 1 },
  ];
  posts.forEach(p => {
    db.posts.push({ _id: newId(), ...p, mediaKeys: [], recipientSubs: [], createdAt: new Date(Date.now() - p.ago * 86400000) });
  });

  // Biometric data (7 days)
  const now = new Date();
  for (let day = 6; day >= 0; day--) {
    const d = new Date(now); d.setDate(d.getDate() - day);
    const ds = d.toISOString().split('T')[0];
    const hr = 62 + Math.random() * 8;

    for (let h = 0; h < 24; h += 3) {
      const act = (h >= 6 && h <= 8) ? 30 : (h >= 17 && h <= 18) ? 20 : 0;
      db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'heart_rate', value: Math.round(hr + act + Math.random() * 10), unit: 'bpm', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), h) });
    }
    db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'hrv', value: Math.round(45 + Math.random() * 25), unit: 'ms', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 7) });
    db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'spo2', value: Math.round((96 + Math.random() * 3) * 10) / 10, unit: '%', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 6) });
    db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'steps', value: Math.round(6000 + Math.random() * 6000), unit: 'steps', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 22) });
    db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'temperature', value: Math.round((36.2 + Math.random() * 0.8) * 10) / 10, unit: '\u00b0C', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 6) });
    db.biometricReadings.push({ _id: newId(), userSub: 'dev-alex', type: 'stress', value: Math.round(20 + Math.random() * 40), unit: 'score', source: 'smart_ring', recordedAt: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 14) });

    const ss = Math.round(70 + Math.random() * 25);
    db.dailySummaries.push({
      _id: newId(), userSub: 'dev-alex', date: ds,
      heartRate: { avg: Math.round(hr + 5), min: Math.round(hr - 3), max: Math.round(hr + 35), resting: Math.round(hr - 2) },
      hrv: { avg: Math.round(48 + Math.random() * 20), min: Math.round(30 + Math.random() * 10), max: Math.round(60 + Math.random() * 20) },
      spo2: { avg: Math.round((97 + Math.random() * 2) * 10) / 10, min: Math.round((95 + Math.random() * 2) * 10) / 10 },
      temperature: { avg: 36.5, min: 36.1, max: 36.9 },
      sleep: { totalMinutes: Math.round(380 + Math.random() * 100), deepMinutes: Math.round(60 + Math.random() * 40), lightMinutes: Math.round(150 + Math.random() * 50), remMinutes: Math.round(80 + Math.random() * 30), awakeMinutes: Math.round(10 + Math.random() * 20), score: ss },
      steps: { total: Math.round(6000 + Math.random() * 6000), goal: 10000 },
      stress: { avg: Math.round(25 + Math.random() * 20), max: Math.round(50 + Math.random() * 30) },
      wellnessScore: Math.round(60 + Math.random() * 30),
    });
  }

  db.onboarding.push({ _id: newId(), sub: 'dev-alex', favoriteColor: '#5B288E', focusGoal: 'Improve mood', activities: ['Meditation', 'Yoga', 'Running', 'Journaling'], notificationsEnabled: true, completed: true });

  console.log(`  Seeded: ${db.users.length} users, ${db.connections.length} connections, ${db.posts.length} posts, ${db.dailySummaries.length} daily summaries`);
}

// ─── Auth Middleware ─────────────────────────────────────────
function devAuth(req, res, next) {
  const auth = req.headers.authorization || '';
  const token = auth.replace('Bearer ', '').trim();
  if (!token) return res.status(401).json({ message: 'Missing token' });

  const sub = token.startsWith('dev-') ? token.slice(4) : token;
  req.user = { sub, username: sub, claims: { sub, preferred_username: sub } };

  // Ensure user profile exists
  if (!db.users.find(u => u.sub === sub)) {
    db.users.push({ _id: newId(), sub, name: '', username: sub, bio: '', location: '', avatarKey: '' });
  }
  next();
}

// ─── Helper ─────────────────────────────────────────────────
function findUser(sub) { return db.users.find(u => u.sub === sub); }
function userProfile(u) {
  if (!u) return null;
  return { _id: u._id, sub: u.sub, name: u.name, username: u.username, bio: u.bio, location: u.location, avatarUrl: '' };
}

// ─── Auth Routes ────────────────────────────────────────────
app.post('/auth/dev-login', (req, res) => {
  const { username, name } = req.body;
  if (!username) return res.status(400).json({ message: 'Username required' });

  const sub = `dev-${username.toLowerCase().replace(/[^a-z0-9]/g, '')}`;
  let user = findUser(sub);
  if (user) {
    user.name = name || user.name || username;
    user.username = username.toLowerCase();
  } else {
    user = { _id: newId(), sub, name: name || username, username: username.toLowerCase(), bio: '', location: '', avatarKey: '' };
    db.users.push(user);
  }

  res.json({ accessToken: `dev-${sub}`, idToken: `dev-${sub}`, refreshToken: `dev-refresh-${sub}`, sub, username: user.username, name: user.name });
});

// ─── User Routes ────────────────────────────────────────────
app.get('/user/claims', devAuth, (req, res) => { res.json({ sub: req.user.sub, username: req.user.username }); });
app.get('/user/me', devAuth, (req, res) => {
  const u = findUser(req.user.sub);
  res.json({ profile: userProfile(u) });
});
app.put('/user/me', devAuth, (req, res) => {
  const u = findUser(req.user.sub);
  if (u) { Object.assign(u, req.body); }
  res.json({ profile: userProfile(u) });
});

// ─── People Routes ──────────────────────────────────────────
app.get('/people/me', devAuth, (req, res) => {
  const u = findUser(req.user.sub);
  res.json({ me: userProfile(u) });
});

app.get('/people/inner-circle', devAuth, (req, res) => {
  const me = findUser(req.user.sub);
  if (!me) return res.json({ innerCircle: [] });
  const conns = db.connections.filter(c => c.tier === 'inner_circle' && (c.userA === me._id || c.userB === me._id));
  const others = conns.map(c => c.userA === me._id ? c.userB : c.userA);
  const profiles = others.map(id => userProfile(db.users.find(u => u._id === id))).filter(Boolean);
  res.json({ innerCircle: profiles });
});

app.get('/people/connections', devAuth, (req, res) => {
  const me = findUser(req.user.sub);
  if (!me) return res.json({ connections: [] });
  const conns = db.connections.filter(c => c.tier === 'connection' && (c.userA === me._id || c.userB === me._id));
  const others = conns.map(c => c.userA === me._id ? c.userB : c.userA);
  const profiles = others.map(id => userProfile(db.users.find(u => u._id === id))).filter(Boolean);
  res.json({ connections: profiles });
});

app.get('/people/suggestions', devAuth, (req, res) => {
  const me = findUser(req.user.sub);
  if (!me) return res.json({ suggestions: [] });

  const connectedIds = new Set();
  db.connections.forEach(c => {
    if (c.userA === me._id) connectedIds.add(c.userB);
    if (c.userB === me._id) connectedIds.add(c.userA);
  });

  const pendingSubs = new Set([me.sub]);
  db.friendRequests.filter(r => r.status === 'pending' && (r.fromSub === me.sub || r.toSub === me.sub))
    .forEach(r => { pendingSubs.add(r.fromSub); pendingSubs.add(r.toSub); });

  const suggestions = db.users
    .filter(u => u._id !== me._id && !connectedIds.has(u._id) && !pendingSubs.has(u.sub))
    .map(u => userProfile(u));

  res.json({ suggestions });
});

app.get('/people/requests', devAuth, (req, res) => {
  const incoming = db.friendRequests.filter(r => r.toSub === req.user.sub && r.status === 'pending');
  const requests = incoming.map(r => ({
    ...r,
    fromUser: userProfile(findUser(r.fromSub)),
  }));
  res.json({ requests });
});

app.post('/people/request/:sub', devAuth, (req, res) => {
  const fromSub = req.user.sub;
  const toSub = req.params.sub;
  if (fromSub === toSub) return res.status(400).json({ message: 'Cannot request yourself' });
  const exists = db.friendRequests.find(r => r.fromSub === fromSub && r.toSub === toSub && r.status === 'pending');
  if (exists) return res.status(400).json({ message: 'Already sent' });
  const req_ = { _id: newId(), fromSub, toSub, status: 'pending', createdAt: new Date() };
  db.friendRequests.push(req_);
  res.status(201).json({ request: req_ });
});

app.post('/people/request/:requestId/accept', devAuth, (req, res) => {
  const r = db.friendRequests.find(f => f._id === req.params.requestId);
  if (!r) return res.status(404).json({ message: 'Not found' });
  if (r.toSub !== req.user.sub) return res.status(403).json({ message: 'Forbidden' });
  r.status = 'accepted';

  const fromUser = findUser(r.fromSub);
  const toUser = findUser(r.toSub);
  if (fromUser && toUser) {
    const a = fromUser._id < toUser._id ? fromUser._id : toUser._id;
    const b = a === fromUser._id ? toUser._id : fromUser._id;
    if (!db.connections.find(c => c.userA === a && c.userB === b)) {
      db.connections.push({ _id: newId(), userA: a, userB: b, tier: 'connection' });
    }
  }
  res.json({ message: 'Request accepted' });
});

app.post('/people/request/:requestId/decline', devAuth, (req, res) => {
  const r = db.friendRequests.find(f => f._id === req.params.requestId);
  if (!r) return res.status(404).json({ message: 'Not found' });
  r.status = 'declined';
  res.json({ message: 'Request declined' });
});

app.post('/people/:sub/tier', devAuth, (req, res) => {
  const me = findUser(req.user.sub);
  const target = findUser(req.params.sub);
  const { tier } = req.body;
  if (!me || !target || !['connection', 'inner_circle'].includes(tier)) return res.status(400).json({ message: 'Invalid' });
  const a = me._id < target._id ? me._id : target._id;
  const b = a === me._id ? target._id : me._id;
  const conn = db.connections.find(c => c.userA === a && c.userB === b);
  if (conn) conn.tier = tier;
  res.json({ message: 'Updated', tier });
});

app.delete('/people/:sub', devAuth, (req, res) => {
  const me = findUser(req.user.sub);
  const target = findUser(req.params.sub);
  if (!me || !target) return res.status(404).json({ message: 'Not found' });
  const a = me._id < target._id ? me._id : target._id;
  const b = a === me._id ? target._id : me._id;
  const idx = db.connections.findIndex(c => c.userA === a && c.userB === b);
  if (idx >= 0) db.connections.splice(idx, 1);
  res.json({ message: 'Removed' });
});

// ─── Chat Routes ────────────────────────────────────────────
app.get('/chat/unread-count', devAuth, (req, res) => {
  const unread = db.messages.filter(m => m.toSub === req.user.sub && !m.readAt).length;
  res.json({ unread });
});

app.get('/chat/conversations', devAuth, (req, res) => {
  const mySub = req.user.sub;
  const myMessages = db.messages.filter(m => m.fromSub === mySub || m.toSub === mySub)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const map = new Map();
  for (const m of myMessages) {
    const other = m.fromSub === mySub ? m.toSub : m.fromSub;
    if (!map.has(other)) map.set(other, m);
  }

  const conversations = Array.from(map.entries()).map(([otherSub, lastMsg]) => ({
    otherSub,
    otherUser: userProfile(findUser(otherSub)) || { sub: otherSub, name: otherSub },
    lastMessage: lastMsg.text,
    lastAt: lastMsg.createdAt,
  }));

  res.json({ conversations });
});

app.post('/chat/conversation/:otherSub', devAuth, (req, res) => {
  const mySub = req.user.sub;
  const otherSub = req.params.otherSub;
  const key = [mySub, otherSub].sort().join('|');
  let convo = db.conversations.find(c => c.membersKey === key);
  if (!convo) {
    convo = { _id: newId(), members: [mySub, otherSub], membersKey: key, lastMessage: '', lastMessageAt: null };
    db.conversations.push(convo);
  }
  res.json({ conversation: convo });
});

app.get('/chat/messages/:conversationId', devAuth, (req, res) => {
  const mySub = req.user.sub;
  const messages = db.messages.filter(m => m.conversationId === req.params.conversationId)
    .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));

  // Mark as read
  messages.forEach(m => { if (m.toSub === mySub && !m.readAt) m.readAt = new Date(); });

  res.json({ messages });
});

app.post('/chat/messages/:conversationId', devAuth, (req, res) => {
  const mySub = req.user.sub;
  const { text } = req.body;
  if (!text?.trim()) return res.status(400).json({ message: 'Empty' });

  const convo = db.conversations.find(c => c._id === req.params.conversationId);
  if (!convo) return res.status(404).json({ message: 'Not found' });

  const toSub = convo.members.find(s => s !== mySub);
  const msg = { _id: newId(), conversationId: convo._id, fromSub: mySub, toSub, text: text.trim(), readAt: null, createdAt: new Date() };
  db.messages.push(msg);

  convo.lastMessage = text.trim();
  convo.lastMessageAt = new Date();

  const io = app.get('io');
  if (io) {
    io.to(`conv:${convo._id}`).emit('newMessage', msg);
    io.to(`user:${toSub}`).emit('inboxUpdate', { conversationId: convo._id });
  }

  res.status(201).json({ message: msg });
});

// ─── Posts Routes ───────────────────────────────────────────
app.post('/posts', devAuth, (req, res) => {
  const { caption, visibility, mediaKeys, recipientSubs } = req.body;
  const post = {
    _id: newId(), authorSub: req.user.sub, caption: caption || '',
    visibility: visibility || 'public', mediaKeys: mediaKeys || [],
    recipientSubs: recipientSubs || [], createdAt: new Date(),
  };
  db.posts.push(post);
  res.status(201).json({ post });
});

app.get('/posts/mine', devAuth, (req, res) => {
  const posts = db.posts.filter(p => p.authorSub === req.user.sub)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .map(p => ({ ...p, authorName: findUser(p.authorSub)?.name || p.authorSub }));
  res.json({ posts });
});

// ─── Feed Routes ────────────────────────────────────────────
app.get('/feed/home', devAuth, (req, res) => {
  const mySub = req.user.sub;
  const me = findUser(mySub);
  if (!me) return res.json({ posts: [] });

  // Find connected subs
  const connectedSubs = new Set();
  const innerSubs = new Set();
  db.connections.forEach(c => {
    const otherId = c.userA === me._id ? c.userB : (c.userB === me._id ? c.userA : null);
    if (!otherId) return;
    const other = db.users.find(u => u._id === otherId);
    if (!other) return;
    connectedSubs.add(other.sub);
    if (c.tier === 'inner_circle') innerSubs.add(other.sub);
  });

  const visible = db.posts.filter(p => {
    if (p.authorSub === mySub) return true;
    if (p.visibility === 'public') return true;
    if (p.visibility === 'connections' && (connectedSubs.has(p.authorSub) || innerSubs.has(p.authorSub))) return true;
    if (p.visibility === 'innerCircle' && innerSubs.has(p.authorSub)) return true;
    if (p.recipientSubs?.includes(mySub)) return true;
    return false;
  });

  const posts = visible
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 50)
    .map(p => ({ ...p, authorName: findUser(p.authorSub)?.name || p.authorSub }));

  res.json({ posts });
});

app.get('/feed/explore', devAuth, (req, res) => {
  const posts = db.posts.filter(p => p.visibility === 'public')
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 50)
    .map(p => ({ ...p, authorName: findUser(p.authorSub)?.name || p.authorSub }));
  res.json({ posts });
});

// ─── Biometrics Routes ──────────────────────────────────────
app.post('/biometrics/reading', devAuth, (req, res) => {
  const { type, value, unit, source, metadata, recordedAt } = req.body;
  const reading = { _id: newId(), userSub: req.user.sub, type, value, unit, source: source || 'smart_ring', metadata: metadata || {}, recordedAt: recordedAt ? new Date(recordedAt) : new Date() };
  db.biometricReadings.push(reading);
  res.status(201).json({ reading });
});

app.post('/biometrics/batch', devAuth, (req, res) => {
  const { readings } = req.body;
  if (!Array.isArray(readings)) return res.status(400).json({ error: 'Array required' });
  readings.forEach(r => {
    db.biometricReadings.push({ _id: newId(), userSub: req.user.sub, ...r, recordedAt: r.recordedAt ? new Date(r.recordedAt) : new Date() });
  });
  res.status(201).json({ count: readings.length });
});

app.get('/biometrics/history', devAuth, (req, res) => {
  const { type, from, to, limit } = req.query;
  let readings = db.biometricReadings.filter(r => r.userSub === req.user.sub);
  if (type) readings = readings.filter(r => r.type === type);
  if (from) readings = readings.filter(r => new Date(r.recordedAt) >= new Date(from));
  if (to) readings = readings.filter(r => new Date(r.recordedAt) <= new Date(to));
  readings.sort((a, b) => new Date(b.recordedAt) - new Date(a.recordedAt));
  res.json({ readings: readings.slice(0, parseInt(limit) || 100) });
});

app.get('/biometrics/latest', devAuth, (req, res) => {
  const types = ['heart_rate', 'hrv', 'spo2', 'temperature', 'steps', 'stress'];
  const latest = {};
  types.forEach(type => {
    const r = db.biometricReadings.filter(r => r.userSub === req.user.sub && r.type === type)
      .sort((a, b) => new Date(b.recordedAt) - new Date(a.recordedAt))[0];
    if (r) latest[type] = r;
  });
  res.json({ latest });
});

app.get('/biometrics/summary/:date', devAuth, (req, res) => {
  const summary = db.dailySummaries.find(s => s.userSub === req.user.sub && s.date === req.params.date);
  res.json({ summary: summary || null });
});

app.get('/biometrics/summaries', devAuth, (req, res) => {
  const { from, to } = req.query;
  if (!from || !to) return res.status(400).json({ error: 'from and to required' });
  const summaries = db.dailySummaries.filter(s => s.userSub === req.user.sub && s.date >= from && s.date <= to)
    .sort((a, b) => b.date.localeCompare(a.date));
  res.json({ summaries });
});

// ─── Onboarding Routes ──────────────────────────────────────
app.get('/onboarding/me', devAuth, (req, res) => {
  const ob = db.onboarding.find(o => o.sub === req.user.sub);
  res.json({ onboarding: ob || null });
});
app.get('/onboarding/status', devAuth, (req, res) => {
  const ob = db.onboarding.find(o => o.sub === req.user.sub);
  res.json({ completed: ob?.completed || false });
});
app.post('/onboarding', devAuth, (req, res) => {
  let ob = db.onboarding.find(o => o.sub === req.user.sub);
  if (ob) { Object.assign(ob, req.body); }
  else { ob = { _id: newId(), sub: req.user.sub, ...req.body }; db.onboarding.push(ob); }
  res.json({ onboarding: ob });
});

// ─── Vault Routes ───────────────────────────────────────────
app.get('/vault/landing', devAuth, (req, res) => {
  res.json({ categories: ['family', 'friends', 'events', 'holidays', 'work', 'school', 'other'].map(c => ({ category: c, count: 0, preview: [] })) });
});
app.get('/vault/items', devAuth, (req, res) => { res.json({ items: [] }); });

// ─── Health ─────────────────────────────────────────────────
app.get('/health', (req, res) => { res.json({ status: 'ok', service: 'MUUD Prototype', mode: 'dev' }); });

// ─── Error Handler ──────────────────────────────────────────
app.use((err, req, res, _next) => {
  console.error(err.stack || err.message);
  res.status(500).json({ message: 'Internal server error' });
});

// ─── Start Server ───────────────────────────────────────────
seedData();

const PORT = parseInt(process.env.PORT);
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: true, credentials: true } });

io.use((socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) return next(new Error('Missing token'));
  const sub = token.startsWith('dev-') ? token.slice(4) : token;
  socket.user = { sub };
  next();
});

io.on('connection', (socket) => {
  const sub = socket.user?.sub;
  if (sub) socket.join(`user:${sub}`);
  socket.on('joinConversation', (id) => { if (id) socket.join(`conv:${id}`); });
  socket.on('leaveConversation', (id) => { if (id) socket.leave(`conv:${id}`); });
});

app.set('io', io);

server.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('  ========================================');
  console.log('   MUUD HEALTH PROTOTYPE');
  console.log('  ========================================');
  console.log(`   Open: http://localhost:${PORT}`);
  console.log('');
  console.log('   Demo accounts:');
  console.log('     alex  (Alex Johnson)');
  console.log('     sam   (Sam Rivera)');
  console.log('     jordan (Jordan Lee)');
  console.log('');
  console.log('   In-memory data (resets on restart)');
  console.log('  ========================================');
  console.log('');
});
