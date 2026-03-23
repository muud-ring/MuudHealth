// Muud Health Prototype — SPA Client
(function() {
  'use strict';

  const API = '';  // Same origin
  let token = null;
  let currentUser = null;
  let currentConvoId = null;
  let currentConvoPartner = null;

  // ─── API Client ───────────────────────────────────────────
  async function api(method, path, body) {
    const opts = {
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (token) opts.headers['Authorization'] = `Bearer ${token}`;
    if (body) opts.body = JSON.stringify(body);

    const res = await fetch(`${API}${path}`, opts);
    if (!res.ok) {
      const err = await res.json().catch(() => ({ message: res.statusText }));
      throw new Error(err.message || 'Request failed');
    }
    return res.json();
  }

  // ─── Auth ─────────────────────────────────────────────────
  window.loginAs = async function(username, name) {
    try {
      const data = await api('POST', '/auth/dev-login', { username, name });
      token = data.accessToken;
      currentUser = { sub: data.sub, username: data.username, name: data.name };
      localStorage.setItem('muud_token', token);
      localStorage.setItem('muud_user', JSON.stringify(currentUser));
      enterApp();
    } catch (e) {
      alert('Login failed: ' + e.message);
    }
  };

  window.loginCustom = async function() {
    const username = document.getElementById('custom-username').value.trim();
    const name = document.getElementById('custom-name').value.trim();
    if (!username) return alert('Username required');
    window.loginAs(username, name || username);
  };

  window.logout = function() {
    token = null;
    currentUser = null;
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

    // Hide overlays
    document.querySelectorAll('.overlay-screen').forEach(el => el.classList.remove('active'));

    // Load data for tab
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
    loadUnreadCount();
  }

  // ─── Home Tab ─────────────────────────────────────────────
  async function loadHome() {
    const name = currentUser?.name || 'there';
    const hour = new Date().getHours();
    const greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    document.getElementById('greeting').innerHTML = `
      <h2>${greeting}, ${name.split(' ')[0]}!</h2>
      <p>${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</p>
    `;

    // Load today's summary
    const today = new Date().toISOString().split('T')[0];
    try {
      const { summary } = await api('GET', `/biometrics/summary/${today}`);
      if (summary) {
        document.getElementById('score-circle').textContent = summary.wellnessScore || '--';
        document.getElementById('wellness-details').innerHTML = `
          <div>Sleep: ${summary.sleep ? Math.round(summary.sleep.totalMinutes / 60) + 'h ' + (summary.sleep.totalMinutes % 60) + 'm' : 'N/A'}</div>
          <div>Steps: ${summary.steps ? summary.steps.total.toLocaleString() : 'N/A'} / ${summary.steps?.goal?.toLocaleString() || '10,000'}</div>
          <div>HR: ${summary.heartRate ? summary.heartRate.avg + ' bpm' : 'N/A'}</div>
          <div>Stress: ${summary.stress ? summary.stress.avg + '/100' : 'N/A'}</div>
        `;

        const grid = document.getElementById('metrics-grid');
        grid.innerHTML = '';
        const metrics = [
          { icon: '\u2764\ufe0f', label: 'Heart Rate', value: summary.heartRate?.avg, unit: 'bpm', color: 'var(--red)' },
          { icon: '\ud83d\udca4', label: 'Sleep Score', value: summary.sleep?.score, unit: '/100', color: 'var(--blue)' },
          { icon: '\ud83d\udeb6', label: 'Steps', value: summary.steps?.total?.toLocaleString(), unit: '', color: 'var(--green)' },
          { icon: '\ud83e\udde0', label: 'HRV', value: summary.hrv?.avg, unit: 'ms', color: 'var(--purple)' },
          { icon: '\ud83c\udf21\ufe0f', label: 'Temperature', value: summary.temperature?.avg, unit: '\u00b0C', color: 'var(--orange)' },
          { icon: '\ud83d\ude2e\u200d\ud83d\udca8', label: 'SpO2', value: summary.spo2?.avg, unit: '%', color: 'var(--blue)' },
        ];
        metrics.forEach(m => {
          if (m.value != null) {
            grid.innerHTML += `
              <div class="metric-card">
                <div class="metric-icon">${m.icon}</div>
                <div class="metric-value">${m.value}<span class="metric-unit"> ${m.unit}</span></div>
                <div class="metric-label">${m.label}</div>
              </div>`;
          }
        });
      }
    } catch (e) {
      document.getElementById('score-circle').textContent = '--';
    }

    // Load feed
    try {
      const { posts } = await api('GET', '/feed/home');
      renderPosts(posts, 'home-feed');
    } catch (e) {
      document.getElementById('home-feed').innerHTML = '<div class="empty-state"><p>No activity yet</p></div>';
    }
  }

  // ─── Trends Tab ───────────────────────────────────────────
  async function loadTrends() {
    const to = new Date().toISOString().split('T')[0];
    const from = new Date(Date.now() - 6 * 86400000).toISOString().split('T')[0];

    try {
      const { summaries } = await api('GET', `/biometrics/summaries?from=${from}&to=${to}`);
      const sorted = (summaries || []).sort((a, b) => a.date.localeCompare(b.date));
      const cards = document.getElementById('trends-cards');
      cards.innerHTML = '';

      // Heart Rate trend
      if (sorted.some(s => s.heartRate)) {
        cards.innerHTML += trendCard('Heart Rate', sorted.map(s => s.heartRate?.avg || 0), sorted, 'bpm', 'var(--red)');
      }
      // Sleep trend
      if (sorted.some(s => s.sleep)) {
        cards.innerHTML += trendCard('Sleep Score', sorted.map(s => s.sleep?.score || 0), sorted, '/100', 'var(--blue)');
      }
      // Steps trend
      if (sorted.some(s => s.steps)) {
        cards.innerHTML += trendCard('Steps', sorted.map(s => s.steps?.total || 0), sorted, '', 'var(--green)');
      }
      // HRV trend
      if (sorted.some(s => s.hrv)) {
        cards.innerHTML += trendCard('HRV', sorted.map(s => s.hrv?.avg || 0), sorted, 'ms', 'var(--purple)');
      }
      // Wellness score trend
      if (sorted.some(s => s.wellnessScore)) {
        cards.innerHTML += trendCard('Wellness Score', sorted.map(s => s.wellnessScore || 0), sorted, '/100', 'var(--purple)');
      }

      // Daily summaries list
      const hist = document.getElementById('trends-history');
      hist.innerHTML = '';
      sorted.reverse().forEach(s => {
        hist.innerHTML += `
          <div class="summary-card">
            <div class="summary-date">${formatDate(s.date)}</div>
            <div class="summary-grid">
              <div class="summary-item"><div class="val">${s.wellnessScore || '--'}</div><div class="lbl">Wellness</div></div>
              <div class="summary-item"><div class="val">${s.heartRate?.avg || '--'}</div><div class="lbl">HR (avg)</div></div>
              <div class="summary-item"><div class="val">${s.sleep?.score || '--'}</div><div class="lbl">Sleep</div></div>
              <div class="summary-item"><div class="val">${s.steps?.total?.toLocaleString() || '--'}</div><div class="lbl">Steps</div></div>
              <div class="summary-item"><div class="val">${s.hrv?.avg || '--'}</div><div class="lbl">HRV</div></div>
              <div class="summary-item"><div class="val">${s.stress?.avg || '--'}</div><div class="lbl">Stress</div></div>
            </div>
          </div>`;
      });
    } catch (e) {
      document.getElementById('trends-cards').innerHTML = '<div class="empty-state"><p>No trends data yet</p></div>';
    }
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
  async function loadJournal() {
    try {
      const { posts } = await api('GET', '/posts/mine');
      const list = document.getElementById('journal-list');
      if (!posts || posts.length === 0) {
        list.innerHTML = '<div class="empty-state"><div class="empty-icon">&#128221;</div><p>No journal entries yet. Start writing!</p></div>';
      } else {
        renderPosts(posts, 'journal-list');
      }
    } catch (e) {
      document.getElementById('journal-list').innerHTML = '<div class="empty-state"><p>Could not load journal</p></div>';
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

  window.submitJournal = async function() {
    const caption = document.getElementById('journal-text').value.trim();
    if (!caption) return;
    const visibility = document.getElementById('journal-visibility').value;

    try {
      await api('POST', '/posts', { caption, visibility, mediaKeys: [] });
      hideJournalCreate();
      loadJournal();
    } catch (e) {
      alert('Failed to post: ' + e.message);
    }
  };

  // ─── People Tab ───────────────────────────────────────────
  async function loadPeople() {
    // Inner circle
    try {
      const { innerCircle } = await api('GET', '/people/inner-circle');
      const ring = document.getElementById('inner-circle-ring');
      if (!innerCircle || innerCircle.length === 0) {
        ring.innerHTML = '<div class="empty-state" style="padding:12px"><p>No inner circle yet</p></div>';
      } else {
        ring.innerHTML = innerCircle.map(p => `
          <div class="circle-person" onclick="viewProfile('${p.sub}')">
            <div class="circle-avatar">${initials(p.name)}</div>
            <div class="circle-name">${p.name || p.username}</div>
          </div>
        `).join('');
      }
    } catch(e) {}

    // Requests
    try {
      const { requests } = await api('GET', '/people/requests');
      const list = document.getElementById('requests-list');
      const badge = document.getElementById('request-count');
      if (!requests || requests.length === 0) {
        list.innerHTML = '<div style="font-size:13px;color:var(--grey);padding:8px">No pending requests</div>';
        badge.style.display = 'none';
      } else {
        badge.style.display = 'inline';
        badge.textContent = requests.length;
        list.innerHTML = requests.map(r => {
          const u = r.fromUser || {};
          return `
            <div class="person-tile">
              <span class="avatar-sm">${initials(u.name)}</span>
              <div class="person-info">
                <div class="name">${u.name || 'Unknown'}</div>
                <div class="bio">Wants to connect</div>
              </div>
              <div class="person-actions">
                <button class="btn-accept" onclick="acceptRequest('${r._id}')">Accept</button>
                <button class="btn-decline" onclick="declineRequest('${r._id}')">Decline</button>
              </div>
            </div>`;
        }).join('');
      }
    } catch(e) {}

    // Connections
    try {
      const { connections } = await api('GET', '/people/connections');
      const list = document.getElementById('connections-list');
      if (!connections || connections.length === 0) {
        list.innerHTML = '<div class="empty-state"><p>No connections yet</p></div>';
      } else {
        list.innerHTML = connections.map(p => `
          <div class="person-tile" onclick="viewProfile('${p.sub}')">
            <span class="avatar-sm">${initials(p.name)}</span>
            <div class="person-info">
              <div class="name">${p.name || p.username}</div>
              <div class="bio">${p.bio || p.location || ''}</div>
            </div>
          </div>
        `).join('');
      }
    } catch(e) {}

    // Suggestions
    try {
      const { suggestions } = await api('GET', '/people/suggestions');
      const list = document.getElementById('suggestions-list');
      if (!suggestions || suggestions.length === 0) {
        list.innerHTML = '<div style="font-size:13px;color:var(--grey);padding:8px">No suggestions right now</div>';
      } else {
        list.innerHTML = suggestions.map(p => `
          <div class="person-tile">
            <span class="avatar-sm">${initials(p.name)}</span>
            <div class="person-info">
              <div class="name">${p.name || p.username}</div>
              <div class="bio">${p.bio || ''}</div>
            </div>
            <div class="person-actions">
              <button class="btn-connect" onclick="sendRequest('${p.sub}')">Connect</button>
            </div>
          </div>
        `).join('');
      }
    } catch(e) {}
  }

  window.acceptRequest = async function(id) {
    try {
      await api('POST', `/people/request/${id}/accept`);
      loadPeople();
    } catch(e) { alert(e.message); }
  };

  window.declineRequest = async function(id) {
    try {
      await api('POST', `/people/request/${id}/decline`);
      loadPeople();
    } catch(e) { alert(e.message); }
  };

  window.sendRequest = async function(sub) {
    try {
      await api('POST', `/people/request/${sub}`);
      loadPeople();
    } catch(e) { alert(e.message); }
  };

  window.viewProfile = async function(sub) {
    showScreen('profile');
    const content = document.getElementById('profile-content');
    content.innerHTML = '<div class="loading">Loading...</div>';

    try {
      // Use suggestions/connections to find the profile info
      const [connRes, icRes] = await Promise.all([
        api('GET', '/people/connections'),
        api('GET', '/people/inner-circle'),
      ]);
      const all = [...(connRes.connections || []), ...(icRes.innerCircle || [])];
      const p = all.find(u => u.sub === sub);

      if (p) {
        content.innerHTML = `
          <div class="profile-card">
            <div class="avatar-lg">${initials(p.name)}</div>
            <div class="profile-name">${p.name}</div>
            <div class="profile-username">@${p.username || ''}</div>
            ${p.bio ? `<div class="profile-bio">${p.bio}</div>` : ''}
            ${p.location ? `<div class="profile-location">${p.location}</div>` : ''}
          </div>
          <button class="btn-primary" onclick="openChat('${p.sub}','${escapeHtml(p.name)}')">Send Message</button>`;
      } else {
        content.innerHTML = '<div class="empty-state"><p>Profile not found</p></div>';
      }
    } catch(e) {
      content.innerHTML = '<div class="empty-state"><p>Could not load profile</p></div>';
    }
  };

  // ─── Explore Tab ──────────────────────────────────────────
  async function loadExplore() {
    try {
      const { posts } = await api('GET', '/feed/explore');
      renderPosts(posts, 'explore-feed');
    } catch(e) {
      document.getElementById('explore-feed').innerHTML = '<div class="empty-state"><p>Nothing to explore yet</p></div>';
    }
  }

  // ─── Chat ─────────────────────────────────────────────────
  async function loadUnreadCount() {
    try {
      const { unread } = await api('GET', '/chat/unread-count');
      const badge = document.getElementById('chat-badge');
      if (unread > 0) {
        badge.style.display = 'flex';
        badge.textContent = unread;
      } else {
        badge.style.display = 'none';
      }
    } catch(e) {}
  }

  async function loadChatList() {
    try {
      const { conversations } = await api('GET', '/chat/conversations');
      const list = document.getElementById('conversations-list');
      if (!conversations || conversations.length === 0) {
        list.innerHTML = '<div class="empty-state"><div class="empty-icon">&#128172;</div><p>No conversations yet</p></div>';
      } else {
        list.innerHTML = conversations.map(c => {
          const u = c.otherUser || {};
          return `
            <div class="conversation-item" onclick="openChatFromConvo('${c.otherSub}','${escapeHtml(u.name || u.username || c.otherSub)}')">
              <span class="avatar-sm">${initials(u.name)}</span>
              <div class="convo-info">
                <div class="convo-name">${u.name || u.username || c.otherSub}</div>
                <div class="convo-preview">${c.lastMessage || ''}</div>
              </div>
              <div class="convo-time">${c.lastAt ? timeAgo(c.lastAt) : ''}</div>
            </div>`;
        }).join('');
      }
    } catch(e) {
      document.getElementById('conversations-list').innerHTML = '<div class="empty-state"><p>Could not load messages</p></div>';
    }
  }

  window.openChatFromConvo = function(sub, name) {
    openChat(sub, name);
  };

  window.openChat = async function(otherSub, otherName) {
    currentConvoPartner = { sub: otherSub, name: otherName };
    document.getElementById('chat-partner-name').textContent = otherName;
    showScreen('chat-detail');

    try {
      const { conversation } = await api('POST', `/chat/conversation/${otherSub}`);
      currentConvoId = conversation._id;
      await loadMessages();
    } catch(e) {
      document.getElementById('chat-messages').innerHTML = '<div class="empty-state"><p>Could not open chat</p></div>';
    }
  };

  async function loadMessages() {
    if (!currentConvoId) return;
    try {
      const { messages } = await api('GET', `/chat/messages/${currentConvoId}`);
      const container = document.getElementById('chat-messages');
      if (!messages || messages.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>Start the conversation!</p></div>';
      } else {
        container.innerHTML = messages.map(m => {
          const mine = m.fromSub === currentUser.sub;
          return `
            <div class="chat-bubble ${mine ? 'mine' : 'theirs'}">
              ${m.text}
              <div class="chat-time">${formatTime(m.createdAt)}</div>
            </div>`;
        }).join('');
        container.scrollTop = container.scrollHeight;
      }
      loadUnreadCount();
    } catch(e) {}
  }

  window.sendChatMessage = async function() {
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    if (!text || !currentConvoId) return;
    input.value = '';

    try {
      await api('POST', `/chat/messages/${currentConvoId}`, { text });
      await loadMessages();
    } catch(e) {
      alert('Failed to send: ' + e.message);
    }
  };

  // ─── Settings ─────────────────────────────────────────────
  async function loadSettings() {
    try {
      const { me } = await api('GET', '/people/me');
      document.getElementById('settings-profile').innerHTML = `
        <div class="avatar-lg">${initials(me.name)}</div>
        <div class="profile-name">${me.name || 'Unknown'}</div>
        <div class="profile-username">@${me.username || ''}</div>
        ${me.bio ? `<div class="profile-bio">${me.bio}</div>` : ''}
        ${me.location ? `<div class="profile-location">${me.location}</div>` : ''}
      `;
    } catch(e) {}
  }

  // ─── Notifications ────────────────────────────────────────
  async function loadNotifications() {
    const list = document.getElementById('notifications-list');
    // Combine friend requests as notifications
    try {
      const { requests } = await api('GET', '/people/requests');
      if (!requests || requests.length === 0) {
        list.innerHTML = '<div class="empty-state"><div class="empty-icon">&#128276;</div><p>No notifications</p></div>';
      } else {
        list.innerHTML = requests.map(r => {
          const u = r.fromUser || {};
          return `
            <div class="notification-item">
              <div class="notification-dot"></div>
              <div class="notification-text"><strong>${u.name || 'Someone'}</strong> wants to connect with you</div>
            </div>`;
        }).join('');
      }
    } catch(e) {
      list.innerHTML = '<div class="empty-state"><p>Could not load notifications</p></div>';
    }
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
    const savedToken = localStorage.getItem('muud_token');
    const savedUser = localStorage.getItem('muud_user');
    if (savedToken && savedUser) {
      token = savedToken;
      currentUser = JSON.parse(savedUser);
      enterApp();
    }
  }

  init();
})();
