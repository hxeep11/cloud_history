// Smooth scroll for anchor links
document.addEventListener('DOMContentLoaded', function() {
    // Add smooth scrolling to all links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Board filter functionality
    const filterButtons = document.querySelectorAll('.filter-btn');
    const boardItems = document.querySelectorAll('.board-item');

    filterButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            filterButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');

            const category = this.getAttribute('data-category');

            boardItems.forEach(item => {
                if (category === 'all' || item.getAttribute('data-category') === category) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    });

    // Search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();

            boardItems.forEach(item => {
                const title = item.querySelector('.board-title a').textContent.toLowerCase();
                if (title.includes(searchTerm)) {
                    item.style.display = 'flex';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    }

    // Like button functionality
    const likeButtons = document.querySelectorAll('.like-btn');
    likeButtons.forEach(button => {
        button.addEventListener('click', function() {
            const currentText = this.textContent;
            const match = currentText.match(/\d+/);
            if (match) {
                const currentCount = parseInt(match[0]);
                const newCount = currentCount + 1;
                this.textContent = currentText.replace(/\d+/, newCount);

                // Add animation
                this.style.transform = 'scale(1.1)';
                setTimeout(() => {
                    this.style.transform = 'scale(1)';
                }, 200);
            }
        });
    });

    // Share button functionality
    const shareButtons = document.querySelectorAll('.share-btn');
    shareButtons.forEach(button => {
        button.addEventListener('click', function() {
            const buttonText = this.textContent;

            if (buttonText.includes('링크')) {
                // Copy current URL to clipboard
                navigator.clipboard.writeText(window.location.href).then(() => {
                    const originalText = this.textContent;
                    this.textContent = '✓ 복사됨!';
                    setTimeout(() => {
                        this.textContent = originalText;
                    }, 2000);
                });
            } else {
                // Simulate share action
                this.textContent = '✓ 공유됨!';
                setTimeout(() => {
                    this.textContent = buttonText;
                }, 2000);
            }
        });
    });

    // Comment form
    const commentForm = document.querySelector('.comment-form');
    if (commentForm) {
        const textarea = commentForm.querySelector('textarea');
        const submitButton = commentForm.querySelector('button');

        submitButton.addEventListener('click', function() {
            const commentText = textarea.value.trim();
            if (commentText) {
                // Simulate comment submission
                alert('댓글이 등록되었습니다!');
                textarea.value = '';
            }
        });
    }

    // Add scroll progress indicator
    const progressBar = document.createElement('div');
    progressBar.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        height: 3px;
        background: linear-gradient(to right, #667eea, #764ba2);
        width: 0%;
        z-index: 9999;
        transition: width 0.1s ease;
    `;
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', function() {
        const windowHeight = window.innerHeight;
        const documentHeight = document.documentElement.scrollHeight - windowHeight;
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollPercent = (scrollTop / documentHeight) * 100;
        progressBar.style.width = scrollPercent + '%';
    });

    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe all cards and posts
    document.querySelectorAll('.feature-card, .post-preview, .blog-card, .board-item').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(el);
    });

    // Mobile menu toggle (if needed in future)
    const navMenu = document.querySelector('.nav-menu');
    if (window.innerWidth <= 768 && navMenu) {
        // Mobile menu logic can be added here
    }

    // Add loading animation
    window.addEventListener('load', function() {
        document.body.style.opacity = '0';
        setTimeout(() => {
            document.body.style.transition = 'opacity 0.3s ease';
            document.body.style.opacity = '1';
        }, 100);
    });

    // Code block copy functionality
    const codeBlocks = document.querySelectorAll('.code-block');
    codeBlocks.forEach(block => {
        const copyButton = document.createElement('button');
        copyButton.textContent = '📋 복사';
        copyButton.style.cssText = `
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.875rem;
        `;

        block.style.position = 'relative';
        block.appendChild(copyButton);

        copyButton.addEventListener('click', function() {
            const code = block.querySelector('code').textContent;
            navigator.clipboard.writeText(code).then(() => {
                copyButton.textContent = '✓ 복사됨!';
                setTimeout(() => {
                    copyButton.textContent = '📋 복사';
                }, 2000);
            });
        });
    });

    console.log('Tech Hub - Powered by ArgoCD & Kubernetes');
});
