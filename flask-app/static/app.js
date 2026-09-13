const form = document.querySelector('#user-form');
const usernameInput = document.querySelector('#username');
const emailInput = document.querySelector('#email');
const usersBody = document.querySelector('#users-body');
const userCount = document.querySelector('#user-count');
const notice = document.querySelector('#notice');
const emptyState = document.querySelector('#empty-state');
const apiStatus = document.querySelector('#api-status');
const statusPill = document.querySelector('.status-pill');
const refreshButton = document.querySelector('#refresh-button');
const cancelButton = document.querySelector('#cancel-button');
const submitButton = document.querySelector('#submit-button');
const formTitle = document.querySelector('#form-title');
const formEyebrow = document.querySelector('#form-eyebrow');

let editingId = null;

function showNotice(message = '') {
  notice.textContent = message;
}

function setApiStatus(online) {
  apiStatus.textContent = online ? 'API connected' : 'API unavailable';
  statusPill.classList.toggle('online', online);
}

function renderUsers(users) {
  usersBody.innerHTML = '';
  userCount.textContent = users.length;
  emptyState.hidden = users.length !== 0;

  users.forEach((user) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${user.id}</td>
      <td>${escapeHtml(user.username)}</td>
      <td>${escapeHtml(user.email)}</td>
      <td><div class="row-actions">
        <button class="button button-quiet" data-action="edit" data-id="${user.id}">Edit</button>
        <button class="button button-danger" data-action="delete" data-id="${user.id}">Delete</button>
      </div></td>`;
    usersBody.appendChild(row);
  });
}

function escapeHtml(value) {
  const element = document.createElement('span');
  element.textContent = value;
  return element.innerHTML;
}

async function loadUsers() {
  showNotice('');
  refreshButton.disabled = true;
  try {
    const response = await fetch('/users');
    if (!response.ok) throw new Error('Could not load users.');
    renderUsers(await response.json());
    setApiStatus(true);
  } catch (error) {
    setApiStatus(false);
    showNotice(error.message);
  } finally {
    refreshButton.disabled = false;
  }
}

async function saveUser(event) {
  event.preventDefault();
  showNotice('');
  submitButton.disabled = true;
  const payload = { username: usernameInput.value.trim(), email: emailInput.value.trim() };
  const url = editingId ? `/users/${editingId}` : '/users';
  const method = editingId ? 'PUT' : 'POST';

  try {
    const response = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!response.ok) throw new Error(editingId ? 'Could not update user.' : 'Could not create user.');
    resetForm();
    await loadUsers();
  } catch (error) {
    showNotice(error.message);
  } finally {
    submitButton.disabled = false;
  }
}

async function deleteUser(id) {
  if (!window.confirm('Delete this user?')) return;
  try {
    const response = await fetch(`/users/${id}`, { method: 'DELETE' });
    if (!response.ok) throw new Error('Could not delete user.');
    await loadUsers();
  } catch (error) {
    showNotice(error.message);
  }
}

function startEditing(id) {
  fetch(`/users/${id}`).then((response) => response.json()).then((result) => {
    const user = result.user;
    editingId = id;
    usernameInput.value = user.username;
    emailInput.value = user.email;
    formEyebrow.textContent = 'EDIT RECORD';
    formTitle.textContent = 'Update user';
    submitButton.textContent = 'Save changes';
    cancelButton.hidden = false;
    usernameInput.focus();
  }).catch(() => showNotice('Could not load that user.'));
}

function resetForm() {
  editingId = null;
  form.reset();
  formEyebrow.textContent = 'NEW RECORD';
  formTitle.textContent = 'Add a user';
  submitButton.textContent = 'Create user';
  cancelButton.hidden = true;
}

usersBody.addEventListener('click', (event) => {
  const button = event.target.closest('button');
  if (!button) return;
  if (button.dataset.action === 'edit') startEditing(button.dataset.id);
  if (button.dataset.action === 'delete') deleteUser(button.dataset.id);
});
form.addEventListener('submit', saveUser);
cancelButton.addEventListener('click', resetForm);
refreshButton.addEventListener('click', loadUsers);
loadUsers();
