// Muud Health Prototype — Self-contained SPA with mock data
(function() {
  'use strict';

  let currentUser = null;
  let currentConvoId = null;
  let currentConvoPartner = null;

  // ─── Mock Data ────────────────────────────────────────────
  const MOCK_USERS = {
    alex: { sub: 'alex-001', username: 'alex', name: 'Alex Johnson', bio: 'Wellness enthusiast. Early riser.', location: 'San Francisco, CA' },
    sam: { sub: 'sam-001', username: 'sam', name: 'Sam Rivera', bio: 'Yoga instructor & mindfulness coach.', location: 'Austin, TX' },
    jordan: { sub: 'jordan-001', username: 'jordan', name: 'Jordan Lee', bio: 'Running + meditation = balance.', location: 'Portland, OR' },
    maya: { sub: 'maya-001', username: 'maya', name: 'Maya Chen', bio: 'Sleep science nerd. Tea lover.', location: 'Seattle, WA' },
    liam: { sub: 'liam-001', username: 'liam', name: 'Liam Brooks', bio: 'CrossFit coach. Nutrition focused.', location: 'Denver, CO' },
    sophia: { sub: 'sophia-001', username: 'sophia', name: 'Sophia Patel', bio: 'Therapist. Journaling advocate.', location: 'New York, NY' },
  };

  function getOtherUsers() {
    if (!currentUser) return [];
    return Object.values(MOCK_USERS).filter(u => u.sub !== currentUser.sub);
  }

  function generateBiometrics(dateStr) {
    const seed = dateStr.split('-').reduce((a, b) => a + parseInt(b), 0);
    const r = (min, max) => Math.floor(min + ((seed * 9301 + 49297) % 233280) / 233280 * (max - min));
    const day = new Date(dateStr + 'T12:00:00').getDay();
    return {
      date: dateStr,
      wellnessScore: r(60, 95),
      heartRate: { avg: r(58, 78), min: r(48, 55), max: r(110, 155) },
      sleep: { totalMinutes: r(360, 510), score: r(55, 95), deep: r(60, 120), rem: r(80, 130), light: r(180, 260) },
      steps: { total: r(4000, 14000), goal: 10000 },
      hrv: { avg: r(30, 70) },
      stress: { avg: r(20, 65) },
      temperature: { avg: (36.2 + (seed % 10) / 10).toFixed(1) },
      spo2: { avg: r(95, 99) },
    };
  }

  function todayStr() { return new Date().toISOString().split('T')[0]; }

  function generatePosts(user) {
    const now = Date.now();
    const others = getOtherUsers();
    const captions = [
      'Morning meditation done. 15 minutes of stillness really sets the tone for the whole day.',
      'Hit 12,000 steps before lunch! The walking meetings idea is working great.',
      'Sleep score was 92 last night. New pillow + no screens after 9pm = magic.',
      'Journaling prompt: What are three things I\'m grateful for today? Answered with genuine surprise.',
      'Started a new breathing exercise routine. Box breathing 4-4-4-4. Feeling centered.',
      'Recovery day today. Light stretching, lots of water, and an early bedtime planned.',
      'Week 3 of consistent tracking. The trends are really motivating - seeing real progress!',
      'Tried a cold shower this morning. Uncomfortable but my HRV was noticeably better after.',
    ];
    return captions.map((caption, i) => ({
      _id: `post-${i}`,
      authorSub: i < 3 ? user.sub : (others[i % others.length] || user).sub,
      authorName: i < 3 ? user.name : (others[i % others.length] || user).name,
      caption,
      visibility: i % 3 === 0 ? 'public' : i % 3 === 1 ? 'connections' : 'innerCircle',
      createdAt: new Date(now - i * 3600000 * (2 + i)).toISOString(),
    }));
  }

  function generateConversations(user) {
    const others = getOtherUsers().slice(0, 3);
    const messages = [
      ['Hey! How was your morning walk?', 'It was great! Got 8000 steps in before 9am.', 'Nice! I need to start doing that.'],
      ['Have you tried the new breathing exercise?', 'Not yet, is it the 4-7-8 one?', 'Yes! It really helps with sleep.'],
      ['Your wellness score was amazing this week!', 'Thanks! Consistency is paying off.', 'What changed for you?', 'Mostly better sleep habits and daily journaling.'],
    ];
    return others.map((other, i) => ({
      _id: `convo-${i}`,
      otherSub: other.sub,
      otherUser: other,
      lastMessage: messages[i][messages[i].length - 1],
      lastAt: new Date(Date.now() - i * 7200000).toISOString(),
      messages: messages[i].map((text, j) => ({
        _id: `msg-${i}-${j}`,
        fromSub: j % 2 === 0 ? other.sub : user.sub,
        text,
        createdAt: new Date(Date.now() - (messages[i].length - j) * 600000 - i * 7200000).toISOString(),
      })),
    }));
  }

  let mockPosts = [];
  let mockConversations = [];
  let userJournalPosts = [];

  // ─── Auth ─────────────────────────────────────────────────
  window.loginAs = function(username, name) {
    const user = MOCK_USERS[username] || { sub: username + '-001', username, name: name || username, bio: '', location: '' };
    currentUser = user;
    localStorage.setItem('muud_token', 'mock-token');
    localStorage.setItem('muud_user', JSON.stringify(currentUser));
    mockPosts = generatePosts(currentUser);
    mockConversations = generateConversations(currentUser);
    userJournalPosts = mockPosts.filter(p => p.authorSub === currentUser.sub);
    enterApp();
  };

  window.loginCustom = function() {
    const username = document.getElementById('custom-username').value.trim();
    const name = document.getElementById('custom-name').value.trim();
    if (!username) return alert('Username required');
    window.loginAs(username, name || username);
  };

  window.logout = function() {
    currentUser = null;
    mockPosts = [];
    mockConversations = [];
    userJournalPosts = [];
    localStorage.removeItem('muud_token');
    localStorage.removeItem('muud_user');
    document.getElementById('login-screen').classList.add('active');
    document.getElementById('app-shell').classList.remove('active');
  };

  // ─── Navigation ───────────────────────────────────────────
  const tabTitles = { home: 'Home', trends: 'Trends', journal: 'Journal', people: 'People', explore: 'Explore' };

  window.switchTab = function(tab) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));
    document.getElementById(`tab-${tab}`).classList.add('active');
    document.querySelector(`.nav-btn[data-tab="${tab}"]`).classList.add('active');
    document.getElementById('top-title').textContent = tabTitles[tab] || 'Muud';
    document.querySelectorAll('.overlay-screen').forEach(el => el.classList.remove('active'));

    if (tab === 'home') loadHome();
    if (tab === 'trends') loadTrends();
    if (tab === 'journal') loadJournal();
    if (tab === 'people') loadPeople();
    if (tab === 'explore') loadExplore();
  };

  window.showScreen = function(name) {
    document.querySelectorAll('.overlay-screen').forEach(el => el.classList.remove('active'));
    const el = document.getElementById(`screen-${name}`);
    if (el) {
      el.classList.add('active');
      if (name === 'chat-list') loadChatList();
      if (name === 'settings') loadSettings();
      if (name === 'notifications') loadNotifications();
    }
  };

  window.hideOverlay = function() {
    document.querySelectorAll('.overlay-screen').forEach(el => el.classList.remove('active'));
  };

  // ─── Enter App ────────────────────────────────────────────
  function enterApp() {
    document.getElementById('login-screen').classList.remove('active');
    document.getElementById('app-shell').classList.add('active');
    switchTab('home');
    updateChatBadge();
  }

  // ─── Home Tab ─────────────────────────────────────────────
  function loadHome() {
    const name = currentUser?.name || 'there';
    const hour = new Date().getHours();
    const greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    document.getElementById('greeting').innerHTML = `
      <h2>${greeting}, ${name.split(' ')[0]}!</h2>
      <p>${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</p>
    `;

    const summary = generateBiometrics(todayStr());
    document.getElementById('score-circle').textContent = summary.wellnessScore;
    document.getElementById('wellness-details').innerHTML = `
      <div>Sleep: ${Math.floor(summary.sleep.totalMinutes / 60)}h ${summary.sleep.totalMinutes % 60}m</div>
      <div>Steps: ${summary.steps.total.toLocaleString()} / ${summary.steps.goal.toLocaleString()}</div>
      <div>HR: ${summary.heartRate.avg} bpm</div>
      <div>Stress: ${summary.stress.avg}/100</div>
    `;

    const grid = document.getElementById('metrics-grid');
    const metrics = [
      { icon: '\u2764\ufe0f', label: 'Heart Rate', value: summary.heartRate.avg, unit: 'bpm' },
      { icon: '\ud83d\udca4', label: 'Sleep Score', value: summary.sleep.score, unit: '/100' },
      { icon: '\ud83d\udeb6', label: 'Steps', value: summary.steps.total.toLocaleString(), unit: '' },
      { icon: '\ud83e\udde0', label: 'HRV', value: summary.hrv.avg, unit: 'ms' },
      { icon: '\ud83c\udf21\ufe0f', label: 'Temperature', value: summary.temperature.avg, unit: '\u00b0C' },
      { icon: '\ud83d\ude2e\u200d\ud83d\udca8', label: 'SpO2', value: summary.spo2.avg, unit: '%' },
    ];
    grid.innerHTML = metrics.map(m => `
      <div class="metric-card">
        <div class="metric-icon">${m.icon}</div>
        <div class="metric-value">${m.value}<span class="metric-unit"> ${m.unit}</span></div>
        <div class="metric-label">${m.label}</div>
      </div>`).join('');

    renderPosts(mockPosts.slice(0, 5), 'home-feed');
  }

  // ─── Trends Tab ───────────────────────────────────────────
  function loadTrends() {
    const days = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(Date.now() - i * 86400000);
      days.push(generateBiometrics(d.toISOString().split('T')[0]));
    }

    const cards = document.getElementById('trends-cards');
    cards.innerHTML = '';
    cards.innerHTML += trendCard('Heart Rate', days.map(d => d.heartRate.avg), days, 'bpm', 'var(--red)');
    cards.innerHTML += trendCard('Sleep Score', days.map(d => d.sleep.score), days, '/100', 'var(--blue)');
    cards.innerHTML += trendCard('Steps', days.map(d => d.steps.total), days, '', 'var(--green)');
    cards.innerHTML += trendCard('HRV', days.map(d => d.hrv.avg), days, 'ms', 'var(--purple)');
    cards.innerHTML += trendCard('Wellness Score', days.map(d => d.wellnessScore), days, '/100', 'var(--purple)');

    const hist = document.getElementById('trends-history');
    hist.innerHTML = '';
    [...days].reverse().forEach(s => {
      hist.innerHTML += `
        <div class="summary-card">
          <div class="summary-date">${formatDate(s.date)}</div>
          <div class="summary-grid">
            <div class="summary-item"><div class="val">${s.wellnessScore}</div><div class="lbl">Wellness</div></div>
            <div class="summary-item"><div class="val">${s.heartRate.avg}</div><div class="lbl">HR (avg)</div></div>
            <div class="summary-item"><div class="val">${s.sleep.score}</div><div class="lbl">Sleep</div></div>
            <div class="summary-item"><div class="val">${s.steps.total.toLocaleString()}</div><div class="lbl">Steps</div></div>
            <div class="summary-item"><div class="val">${s.hrv.avg}</div><div class="lbl">HRV</div></div>
            <div class="summary-item"><div class="val">${s.stress.avg}</div><div class="lbl">Stress</div></div>
          </div>
        </div>`;
    });
  }

  function trendCard(title, values, summaries, unit, color) {
    const max = Math.max(...values, 1);
    const latest = values[values.length - 1];
    const bars = values.map(v => `<div class="trend-bar" style="height:${Math.max((v/max)*100, 4)}%;background:${color}20;border:1px solid ${color}40"></div>`).join('');
    const days = summaries.map(s => {
      const d = new Date(s.date + 'T12:00:00');
      return d.toLocaleDateString('en-US', { weekday: 'short' }).slice(0, 2);
    });

    return `
      <div class="trend-card">
        <h3>${title} <span class="trend-value">${typeof latest === 'number' ? latest.toLocaleString() : latest}${unit ? ' ' + unit : ''}</span></h3>
        <div class="trend-chart">${bars}</div>
        <div class="trend-stats">
          ${days.map(d => `<span>${d}</span>`).join('')}
        </div>
      </div>`;
  }

  // ─── Journal Tab ──────────────────────────────────────────
  function loadJournal() {
    const list = document.getElementById('journal-list');
    if (!userJournalPosts || userJournalPosts.length === 0) {
      list.innerHTML = '<div class="empty-state"><div class="empty-icon">&#128221;</div><p>No journal entries yet. Start writing!</p></div>';
    } else {
      renderPosts(userJournalPosts, 'journal-list');
    }
  }

  window.showJournalCreate = function() {
    document.getElementById('journal-create').style.display = 'block';
    document.getElementById('journal-text').focus();
  };

  window.hideJournalCreate = function() {
    document.getElementById('journal-create').style.display = 'none';
    document.getElementById('journal-text').value = '';
  };

  window.submitJournal = function() {
    const caption = document.getElementById('journal-text').value.trim();
    if (!caption) return;
    const visibility = document.getElementById('journal-visibility').value;
    const post = {
      _id: 'post-user-' + Date.now(),
      authorSub: currentUser.sub,
      authorName: currentUser.name,
      caption,
      visibility,
      createdAt: new Date().toISOString(),
    };
    userJournalPosts.unshift(post);
    mockPosts.unshift(post);
    hideJournalCreate();
    loadJournal();
  };

  // ─── People Tab ───────────────────────────────────────────
  function loadPeople() {
    const others = getOtherUsers();
    const innerCircle = others.slice(0, 2);
    const connections = others.slice(0, 3);
    const suggestions = others.slice(3);

    // Inner circle
    const ring = document.getElementById('inner-circle-ring');
    ring.innerHTML = innerCircle.map(p => `
      <div class="circle-person" onclick="viewProfile('${p.sub}')">
        <div class="circle-avatar">${initials(p.name)}</div>
        <div class="circle-name">${p.name}</div>
      </div>
    `).join('');

    // Requests (mock 1 pending)
    const reqList = document.getElementById('requests-list');
    const badge = document.getElementById('request-count');
    if (suggestions.length > 0) {
      const requester = suggestions[0];
      badge.style.display = 'inline';
      badge.textContent = '1';
      reqList.innerHTML = `
        <div class="person-tile" id="request-tile-${requester.sub}">
          <span class="avatar-sm">${initials(requester.name)}</span>
          <div class="person-info">
            <div class="name">${requester.name}</div>
            <div class="bio">Wants to connect</div>
          </div>
          <div class="person-actions">
            <button class="btn-accept" onclick="acceptRequest('${requester.sub}')">Accept</button>
            <button class="btn-decline" onclick="declineRequest('${requester.sub}')">Decline</button>
          </div>
        </div>`;
    } else {
      badge.style.display = 'none';
      reqList.innerHTML = '<div style="font-size:13px;color:var(--grey);padding:8px">No pending requests</div>';
    }

    // Connections
    const connList = document.getElementById('connections-list');
    connList.innerHTML = connections.map(p => `
      <div class="person-tile" onclick="viewProfile('${p.sub}')">
        <span class="avatar-sm">${initials(p.name)}</span>
        <div class="person-info">
          <div class="name">${p.name}</div>
          <div class="bio">${p.bio || p.location || ''}</div>
        </div>
      </div>
    `).join('');

    // Suggestions
    const sugList = document.getElementById('suggestions-list');
    if (suggestions.length > 1) {
      sugList.innerHTML = suggestions.slice(1).map(p => `
        <div class="person-tile">
          <span class="avatar-sm">${initials(p.name)}</span>
          <div class="person-info">
            <div class="name">${p.name}</div>
            <div class="bio">${p.bio || ''}</div>
          </div>
          <div class="person-actions">
            <button class="btn-connect" onclick="sendRequest('${p.sub}')">Connect</button>
          </div>
        </div>
      `).join('');
    } else {
      sugList.innerHTML = '<div style="font-size:13px;color:var(--grey);padding:8px">No suggestions right now</div>';
    }
  }

  window.acceptRequest = function(sub) {
    const tile = document.getElementById('request-tile-' + sub);
    if (tile) {
      tile.innerHTML = '<div style="padding:12px;color:var(--green);font-size:14px">Connection accepted!</div>';
      const badge = document.getElementById('request-count');
      badge.style.display = 'none';
    }
  };

  window.declineRequest = function(sub) {
    const tile = document.getElementById('request-tile-' + sub);
    if (tile) {
      tile.remove();
      const badge = document.getElementById('request-count');
      badge.style.display = 'none';
    }
  };

  window.sendRequest = function(sub) {
    event.target.textContent = 'Sent';
    event.target.disabled = true;
    event.target.style.opacity = '0.6';
  };

  window.viewProfile = function(sub) {
    showScreen('profile');
    const content = document.getElementById('profile-content');
    const p = Object.values(MOCK_USERS).find(u => u.sub === sub);
    if (p) {
      content.innerHTML = `
        <div class="profile-card">
          <div class="avatar-lg">${initials(p.name)}</div>
          <div class="profile-name">${p.name}</div>
          <div class="profile-username">@${p.username}</div>
          ${p.bio ? `<div class="profile-bio">${p.bio}</div>` : ''}
          ${p.location ? `<div class="profile-location">${p.location}</div>` : ''}
        </div>
        <button class="btn-primary" onclick="openChat('${p.sub}','${escapeHtml(p.name)}')">Send Message</button>`;
    } else {
      content.innerHTML = '<div class="empty-state"><p>Profile not found</p></div>';
    }
  };

  // ─── Explore Tab ──────────────────────────────────────────
  function loadExplore() {
    const publicPosts = mockPosts.filter(p => p.visibility === 'public' || p.authorSub !== currentUser.sub);
    renderPosts(publicPosts, 'explore-feed');
  }

  // ─── Chat ─────────────────────────────────────────────────
  function updateChatBadge() {
    const badge = document.getElementById('chat-badge');
    badge.style.display = 'flex';
    badge.textContent = '2';
  }

  function loadChatList() {
    const list = document.getElementById('conversations-list');
    if (!mockConversations || mockConversations.length === 0) {
      list.innerHTML = '<div class="empty-state"><div class="empty-icon">&#128172;</div><p>No conversations yet</p></div>';
    } else {
      list.innerHTML = mockConversations.map(c => {
        const u = c.otherUser;
        return `
          <div class="conversation-item" onclick="openChatFromConvo('${c.otherSub}','${escapeHtml(u.name)}')">
            <span class="avatar-sm">${initials(u.name)}</span>
            <div class="convo-info">
              <div class="convo-name">${u.name}</div>
              <div class="convo-preview">${c.lastMessage || ''}</div>
            </div>
            <div class="convo-time">${timeAgo(c.lastAt)}</div>
          </div>`;
      }).join('');
    }
  }

  window.openChatFromConvo = function(sub, name) {
    openChat(sub, name);
  };

  window.openChat = function(otherSub, otherName) {
    currentConvoPartner = { sub: otherSub, name: otherName };
    document.getElementById('chat-partner-name').textContent = otherName;
    showScreen('chat-detail');

    // Find or create conversation
    let convo = mockConversations.find(c => c.otherSub === otherSub);
    if (!convo) {
      convo = { _id: 'convo-new-' + Date.now(), otherSub, otherUser: MOCK_USERS[Object.keys(MOCK_USERS).find(k => MOCK_USERS[k].sub === otherSub)] || { name: otherName }, messages: [], lastMessage: '', lastAt: new Date().toISOString() };
      mockConversations.push(convo);
    }
    currentConvoId = convo._id;
    loadMessages();

    // Clear badge
    const badge = document.getElementById('chat-badge');
    badge.style.display = 'none';
  };

  function loadMessages() {
    if (!currentConvoId) return;
    const convo = mockConversations.find(c => c._id === currentConvoId);
    const container = document.getElementById('chat-messages');
    if (!convo || !convo.messages || convo.messages.length === 0) {
      container.innerHTML = '<div class="empty-state"><p>Start the conversation!</p></div>';
    } else {
      container.innerHTML = convo.messages.map(m => {
        const mine = m.fromSub === currentUser.sub;
        return `
          <div class="chat-bubble ${mine ? 'mine' : 'theirs'}">
            ${escapeHtml(m.text)}
            <div class="chat-time">${formatTime(m.createdAt)}</div>
          </div>`;
      }).join('');
      container.scrollTop = container.scrollHeight;
    }
  }

  window.sendChatMessage = function() {
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    if (!text || !currentConvoId) return;
    input.value = '';

    const convo = mockConversations.find(c => c._id === currentConvoId);
    if (convo) {
      convo.messages.push({
        _id: 'msg-' + Date.now(),
        fromSub: currentUser.sub,
        text,
        createdAt: new Date().toISOString(),
      });
      convo.lastMessage = text;
      convo.lastAt = new Date().toISOString();
      loadMessages();

      // Simulate reply after 1.5s
      setTimeout(() => {
        const replies = [
          'That\'s a great point!',
          'I totally agree with you.',
          'Thanks for sharing that!',
          'Interesting, tell me more!',
          'I\'ve been thinking about that too.',
        ];
        convo.messages.push({
          _id: 'msg-reply-' + Date.now(),
          fromSub: currentConvoPartner.sub,
          text: replies[Math.floor(Math.random() * replies.length)],
          createdAt: new Date().toISOString(),
        });
        if (currentConvoId === convo._id) loadMessages();
      }, 1500);
    }
  };

  // ─── Settings ─────────────────────────────────────────────
  function loadSettings() {
    if (!currentUser) return;
    document.getElementById('settings-profile').innerHTML = `
      <div class="avatar-lg">${initials(currentUser.name)}</div>
      <div class="profile-name">${currentUser.name}</div>
      <div class="profile-username">@${currentUser.username}</div>
      ${currentUser.bio ? `<div class="profile-bio">${currentUser.bio}</div>` : ''}
      ${currentUser.location ? `<div class="profile-location">${currentUser.location}</div>` : ''}
    `;
  }

  // ─── Notifications ────────────────────────────────────────
  function loadNotifications() {
    const list = document.getElementById('notifications-list');
    const others = getOtherUsers();
    const notifications = [
      { user: others[0], text: `<strong>${others[0]?.name}</strong> wants to connect with you` },
      { user: others[1], text: `<strong>${others[1]?.name}</strong> liked your journal entry` },
      { user: others[2], text: `Your wellness score improved by 5 points this week!` },
    ].filter(n => n.user || !n.user);

    list.innerHTML = notifications.map(n => `
      <div class="notification-item">
        <div class="notification-dot"></div>
        <div class="notification-text">${n.text}</div>
      </div>
    `).join('');
  }

  // ─── Post Renderer ────────────────────────────────────────
  function renderPosts(posts, containerId) {
    const el = document.getElementById(containerId);
    if (!posts || posts.length === 0) {
      el.innerHTML = '<div class="empty-state"><p>No posts yet</p></div>';
      return;
    }
    el.innerHTML = posts.map(p => `
      <div class="post-card">
        <div class="post-header">
          <span class="avatar-sm">${initials(p.authorName || p.authorSub)}</span>
          <div>
            <div class="post-author">${p.authorName || p.authorSub}</div>
            <div class="post-meta">${timeAgo(p.createdAt)} &middot; ${p.visibility || 'public'}</div>
          </div>
        </div>
        <div class="post-body">${escapeHtml(p.caption || '')}</div>
      </div>
    `).join('');
  }

  // ─── Helpers ──────────────────────────────────────────────
  function initials(name) {
    if (!name) return '?';
    return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  function timeAgo(dateStr) {
    if (!dateStr) return '';
    const diff = Date.now() - new Date(dateStr).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'now';
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}d ago`;
    return new Date(dateStr).toLocaleDateString();
  }

  function formatDate(dateStr) {
    return new Date(dateStr + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  }

  function formatTime(dateStr) {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  }

  // ─── Init ─────────────────────────────────────────────────
  function init() {
    const savedUser = localStorage.getItem('muud_user');
    if (savedUser) {
      try {
        currentUser = JSON.parse(savedUser);
        mockPosts = generatePosts(currentUser);
        mockConversations = generateConversations(currentUser);
        userJournalPosts = mockPosts.filter(p => p.authorSub === currentUser.sub);
        enterApp();
      } catch(e) {
        localStorage.removeItem('muud_user');
        localStorage.removeItem('muud_token');
      }
    }
  }

  init();
})();

